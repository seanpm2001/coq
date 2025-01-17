(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *         Copyright INRIA, CNRS and contributors             *)
(* <O___,, * (see version control and CREDITS file for authors & dates) *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

Require Import Rbase.
Require Import Rfunctions.
Require Import Rseries.
Require Import PartSum.
Local Open Scope R_scope.

  (**********)
Lemma sum_N_predN :
  forall (An:nat -> R) (N:nat),
    (0 < N)%nat -> sum_f_R0 An N = sum_f_R0 An (pred N) + An N.
Proof.
  intros.
  replace N with (S (pred N)).
  rewrite tech5.
  reflexivity.
  apply Nat.lt_succ_pred with 0%nat; assumption.
Qed.

  (**********)
Lemma sum_plus :
  forall (An Bn:nat -> R) (N:nat),
    sum_f_R0 (fun l:nat => An l + Bn l) N = sum_f_R0 An N + sum_f_R0 Bn N.
Proof.
  intros.
  induction  N as [| N HrecN].
  reflexivity.
  do 3 rewrite tech5.
  rewrite HrecN; ring.
Qed.

  (* The main result *)
Theorem cauchy_finite :
  forall (An Bn:nat -> R) (N:nat),
    (0 < N)%nat ->
    sum_f_R0 An N * sum_f_R0 Bn N =
    sum_f_R0 (fun k:nat => sum_f_R0 (fun p:nat => An p * Bn (k - p)%nat) k) N +
    sum_f_R0
    (fun k:nat =>
      sum_f_R0 (fun l:nat => An (S (l + k)) * Bn (N - l)%nat)
      (pred (N - k))) (pred N).
Proof.
  intros; induction  N as [| N HrecN].
  elim (Nat.lt_irrefl _ H).
  cut (N = 0%nat \/ (0 < N)%nat).
  intro; elim H0; intro.
  rewrite H1; simpl; ring.
  replace (pred (S N)) with (S (pred N)).
  do 5 rewrite tech5.
  rewrite Rmult_plus_distr_r; rewrite Rmult_plus_distr_l; rewrite (HrecN H1).
  repeat rewrite Rplus_assoc; apply Rplus_eq_compat_l.
  replace (pred (S N - S (pred N))) with 0%nat.
  rewrite Rmult_plus_distr_l;
    replace
      (sum_f_R0 (fun l:nat => An (S (l + S (pred N))) * Bn (S N - l)%nat) 0) with
      (An (S N) * Bn (S N)).
  repeat rewrite <- Rplus_assoc;
    do 2 rewrite <- (Rplus_comm (An (S N) * Bn (S N)));
      repeat rewrite Rplus_assoc; apply Rplus_eq_compat_l.
  rewrite Nat.sub_diag; cut (N = 1%nat \/ (2 <= N)%nat).
  intro; elim H2; intro.
  rewrite H3; simpl; ring.
  replace
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (l + k)) * Bn (N - l)%nat) (pred (N - k)))
      (pred N)) with
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (pred (N - k)))) (pred (pred N)) +
      sum_f_R0 (fun l:nat => An (S l) * Bn (N - l)%nat) (pred N)).
  replace (sum_f_R0 (fun p:nat => An p * Bn (S N - p)%nat) N) with
    (sum_f_R0 (fun l:nat => An (S l) * Bn (N - l)%nat) (pred N) +
      An 0%nat * Bn (S N)).
  repeat rewrite <- Rplus_assoc;
    rewrite <-
      (Rplus_comm (sum_f_R0 (fun l:nat => An (S l) * Bn (N - l)%nat) (pred N)))
      ; repeat rewrite Rplus_assoc; apply Rplus_eq_compat_l.
  replace
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (l + k)) * Bn (S N - l)%nat)
        (pred (S N - k))) (pred N)) with
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (N - k))) (pred N) +
      Bn (S N) * sum_f_R0 (fun l:nat => An (S l)) (pred N)).
  rewrite (decomp_sum An N H1); rewrite Rmult_plus_distr_r;
    repeat rewrite <- Rplus_assoc; rewrite <- (Rplus_comm (An 0%nat * Bn (S N)));
      repeat rewrite Rplus_assoc; apply Rplus_eq_compat_l.
  repeat rewrite <- Rplus_assoc;
    rewrite <-
      (Rplus_comm (sum_f_R0 (fun i:nat => An (S i)) (pred N) * Bn (S N)))
      ;
      rewrite <-
	(Rplus_comm (Bn (S N) * sum_f_R0 (fun i:nat => An (S i)) (pred N)))
	; rewrite (Rmult_comm (Bn (S N))); repeat rewrite Rplus_assoc;
	  apply Rplus_eq_compat_l.
  replace
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (N - k))) (pred N)) with
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (pred (N - k)))) (pred (pred N)) +
      An (S N) * sum_f_R0 (fun l:nat => Bn (S l)) (pred N)).
  rewrite (decomp_sum Bn N H1); rewrite Rmult_plus_distr_l.
  set
    (Z :=
      sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (pred (N - k)))) (pred (pred N)));
    set (Z2 := sum_f_R0 (fun i:nat => Bn (S i)) (pred N));
      ring.
  rewrite
    (sum_N_predN
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (N - k))) (pred N)).
  replace
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (N - k))) (pred (pred N))) with
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (pred (N - k))) + An (S N) * Bn (S k)) (
	  pred (pred N))).
  rewrite
    (sum_plus
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (pred (N - k)))) (fun k:nat => An (S N) * Bn (S k))
      (pred (pred N))).
  repeat rewrite Rplus_assoc; apply Rplus_eq_compat_l.
  replace (pred (N - pred N)) with 0%nat.
  simpl; rewrite Nat.sub_0_r.
  replace (S (pred N)) with N.
  replace (sum_f_R0 (fun k:nat => An (S N) * Bn (S k)) (pred (pred N))) with
    (sum_f_R0 (fun k:nat => Bn (S k) * An (S N)) (pred (pred N))).
  rewrite <- (scal_sum (fun l:nat => Bn (S l)) (pred (pred N)) (An (S N)));
    rewrite (sum_N_predN (fun l:nat => Bn (S l)) (pred N)).
  replace (S (pred N)) with N.
  ring.
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  apply Nat.lt_succ_lt_pred; apply Nat.lt_le_trans with 2%nat; [ apply Nat.lt_succ_diag_r | assumption ].
  apply sum_eq; intros; apply Rmult_comm.
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  replace (N - pred N)%nat with 1%nat.
  reflexivity.
  pattern N at 1; replace N with (S (pred N)).
  rewrite Nat.sub_succ_l.
  rewrite Nat.sub_diag; reflexivity.
  apply le_n.
  apply Nat.lt_succ_pred with 0%nat; assumption.
  apply sum_eq; intros;
    rewrite
      (sum_N_predN (fun l:nat => An (S (S (l + i))) * Bn (N - l)%nat)
	(pred (N - i))).
  replace (S (S (pred (N - i) + i))) with (S N).
  replace (N - pred (N - i))%nat with (S i).
  reflexivity.
  rewrite <- Nat.sub_1_r; apply INR_eq; repeat rewrite minus_INR.
  rewrite S_INR; simpl; ring.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  apply INR_le; rewrite minus_INR.
  apply Rplus_le_reg_l with (INR i - 1).
  replace (INR i - 1 + INR 1) with (INR i); [ idtac | simpl; ring ].
  replace (INR i - 1 + (INR N - INR i)) with (INR N - INR 1);
    [ idtac | simpl; ring ].
  rewrite <- minus_INR.
  apply le_INR; apply Nat.le_trans with (pred (pred N)).
  assumption.
  rewrite Nat.sub_1_r; apply Nat.le_pred_l.
  apply Nat.le_trans with 2%nat.
  apply Nat.le_succ_diag_r.
  assumption.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  rewrite Nat.sub_1_r.
  apply Nat.le_trans with (pred N).
  apply le_S_n.
  replace (S (pred N)) with N.
  replace (S (pred (N - i))) with (N - i)%nat.
  apply (fun p n m:nat => Nat.add_le_mono_l n m p) with i;
    rewrite Nat.add_comm, Nat.sub_add, Nat.add_comm; [ apply Nat.le_add_r | ].
  apply Nat.le_trans with (pred (pred N));
    [ assumption | apply Nat.le_trans with (pred N); apply Nat.le_pred_l ].
  symmetry; apply Nat.lt_succ_pred with 0%nat.
  apply Nat.add_lt_mono_l with i; rewrite (Nat.add_comm _ (N - i)), Nat.sub_add.
  replace (i + 0)%nat with i; [ idtac | ring ].
  apply Nat.le_lt_trans with (pred (pred N));
    [ assumption | apply Nat.lt_trans with (pred N); apply Nat.lt_pred_l ].
  apply Nat.neq_0_lt_0, Nat.succ_lt_mono.
  replace (S (pred N)) with N.
  apply Nat.lt_le_trans with 2%nat.
  apply Nat.lt_succ_diag_r.
  assumption.
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  apply Nat.neq_0_lt_0; assumption.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  apply Nat.le_pred_l.
  apply INR_eq; rewrite <- Nat.sub_1_r; do 3 rewrite S_INR; rewrite plus_INR;
    repeat rewrite minus_INR.
  simpl; ring.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  apply INR_le.
  rewrite minus_INR.
  apply Rplus_le_reg_l with (INR i - 1).
  replace (INR i - 1 + INR 1) with (INR i); [ idtac | simpl; ring ].
  replace (INR i - 1 + (INR N - INR i)) with (INR N - INR 1);
    [ idtac | simpl; ring ].
  rewrite <- minus_INR.
  apply le_INR.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  rewrite Nat.sub_1_r.
  apply Nat.le_pred_l.
  apply Nat.le_trans with 2%nat.
  apply Nat.le_succ_diag_r.
  assumption.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  apply Nat.lt_le_trans with 1%nat.
  apply Nat.lt_0_succ.
  apply INR_le.
  rewrite <- Nat.sub_1_r.
  repeat rewrite minus_INR.
  apply Rplus_le_reg_l with (INR i - 1).
  replace (INR i - 1 + INR 1) with (INR i); [ idtac | simpl; ring ].
  replace (INR i - 1 + (INR N - INR i - INR 1)) with (INR N - INR 1 - INR 1).
  repeat rewrite <- minus_INR.
  apply le_INR.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  do 2 rewrite Nat.sub_1_r.
  apply le_n.
  apply (fun p n m:nat => Nat.add_le_mono_l n m p) with 1%nat.
  rewrite (Nat.add_comm _ (N - 1)), Nat.sub_add.
  simpl; assumption.
  apply Nat.le_trans with 2%nat; [ apply Nat.le_succ_diag_r | assumption ].
  apply Nat.le_trans with 2%nat; [ apply Nat.le_succ_diag_r | assumption ].
  simpl; ring.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  apply (fun p n m:nat => Nat.add_le_mono_l n m p) with i.
  rewrite (Nat.add_comm _ (N - i)), Nat.sub_add.
  replace (i + 1)%nat with (S i).
  replace N with (S (pred N)).
  apply le_n_S.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_pred_l.
  apply Nat.lt_succ_pred with 0%nat; assumption.
  apply INR_eq; rewrite S_INR; rewrite plus_INR; reflexivity.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  apply Nat.lt_le_trans with 1%nat.
  apply Nat.lt_0_succ.
  apply le_S_n.
  replace (S (pred N)) with N.
  assumption.
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  replace
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (l + k)) * Bn (S N - l)%nat)
        (pred (S N - k))) (pred N)) with
    (sum_f_R0
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (N - k)) + An (S k) * Bn (S N)) (pred N)).
  rewrite
    (sum_plus
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (S (l + k))) * Bn (N - l)%nat)
        (pred (N - k))) (fun k:nat => An (S k) * Bn (S N))).
  apply Rplus_eq_compat_l.
  rewrite scal_sum; reflexivity.
  apply sum_eq; intros; rewrite Rplus_comm;
    rewrite
      (decomp_sum (fun l:nat => An (S (l + i)) * Bn (S N - l)%nat)
	(pred (S N - i))).
  replace (0 + i)%nat with i; [ idtac | ring ].
  rewrite Nat.sub_0_r; apply Rplus_eq_compat_l.
  replace (pred (pred (S N - i))) with (pred (N - i)).
  apply sum_eq; intros.
  replace (S N - S i0)%nat with (N - i0)%nat; [ idtac | reflexivity ].
  replace (S i0 + i)%nat with (S (i0 + i)).
  reflexivity.
  apply INR_eq; rewrite S_INR; do 2 rewrite plus_INR; rewrite S_INR; simpl; ring.
  cut ((N - i)%nat = pred (S N - i)).
  intro; rewrite H5; reflexivity.
  rewrite <- Nat.sub_1_r.
  apply INR_eq; repeat rewrite minus_INR.
  rewrite S_INR; simpl; ring.
  apply Nat.le_trans with N.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  apply Nat.le_succ_diag_r.
  apply (fun p n m:nat => Nat.add_le_mono_l n m p) with i.
  rewrite (Nat.add_comm _ (S N - i)), Nat.sub_add.
  replace (i + 1)%nat with (S i).
  apply le_n_S.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  apply INR_eq; rewrite S_INR; rewrite plus_INR; simpl; ring.
  apply Nat.le_trans with N.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  apply Nat.le_succ_diag_r.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  replace (pred (S N - i)) with (S N - S i)%nat.
  replace (S N - S i)%nat with (N - i)%nat; [ idtac | reflexivity ].
  apply Nat.add_lt_mono_l with i.
  rewrite (Nat.add_comm _ (N - i)), Nat.sub_add.
  replace (i + 0)%nat with i; [ idtac | ring ].
  apply Nat.le_lt_trans with (pred N).
  assumption.
  apply Nat.lt_pred_l, Nat.neq_0_lt_0.
  assumption.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  rewrite <- Nat.sub_1_r.
  apply INR_eq; repeat rewrite minus_INR.
  repeat rewrite S_INR; simpl; ring.
  apply Nat.le_trans with N.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  apply Nat.le_succ_diag_r.
  apply (fun p n m:nat => Nat.add_lt_mono_l n m p) with i.
  rewrite (Nat.add_comm _ (S N - i)), Nat.sub_add.
  replace (i + 1)%nat with (S i).
  apply le_n_S.
  apply Nat.le_trans with (pred N).
  rewrite Nat.add_0_r; assumption.
  apply Nat.le_pred_l.
  apply INR_eq; rewrite S_INR; rewrite plus_INR; simpl; ring.
  apply Nat.le_trans with N.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  apply Nat.le_succ_diag_r.
  apply le_n_S.
  apply Nat.le_trans with (pred N).
  assumption.
  apply Nat.le_pred_l.
  rewrite Rplus_comm.
  rewrite (decomp_sum (fun p:nat => An p * Bn (S N - p)%nat) N).
  rewrite Nat.sub_0_r.
  apply Rplus_eq_compat_l.
  apply sum_eq; intros.
  reflexivity.
  assumption.
  rewrite Rplus_comm.
  rewrite
    (decomp_sum
      (fun k:nat =>
	sum_f_R0 (fun l:nat => An (S (l + k)) * Bn (N - l)%nat) (pred (N - k)))
      (pred N)).
  rewrite Nat.sub_0_r.
  replace (sum_f_R0 (fun l:nat => An (S (l + 0)) * Bn (N - l)%nat) (pred N))
    with (sum_f_R0 (fun l:nat => An (S l) * Bn (N - l)%nat) (pred N)).
  apply Rplus_eq_compat_l.
  apply sum_eq; intros.
  replace (pred (N - S i)) with (pred (pred (N - i))).
  apply sum_eq; intros.
  replace (i0 + S i)%nat with (S (i0 + i)).
  reflexivity.
  apply INR_eq; rewrite S_INR; do 2 rewrite plus_INR; rewrite S_INR; simpl; ring.
  cut (pred (N - i) = (N - S i)%nat).
  intro; rewrite H5; reflexivity.
  rewrite <- Nat.sub_1_r.
  apply INR_eq.
  repeat rewrite minus_INR.
  repeat rewrite S_INR; simpl; ring.
  apply Nat.le_trans with (S (pred (pred N))).
  apply le_n_S; assumption.
  replace (S (pred (pred N))) with (pred N).
  apply Nat.le_pred_l.
  symmetry; apply Nat.lt_succ_pred with 0%nat.
  apply Nat.succ_lt_mono.
  replace (S (pred N)) with N.
  apply Nat.lt_le_trans with 2%nat.
  apply Nat.lt_succ_diag_r.
  assumption.
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  apply (fun p n m:nat => Nat.add_le_mono_l n m p) with i.
  rewrite (Nat.add_comm _ (N - i)), Nat.sub_add.
  replace (i + 1)%nat with (S i).
  replace N with (S (pred N)).
  apply le_n_S.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_pred_l.
  apply Nat.lt_succ_pred with 0%nat; assumption.
  apply INR_eq; rewrite S_INR; rewrite plus_INR; simpl; ring.
  apply Nat.le_trans with (pred (pred N)).
  assumption.
  apply Nat.le_trans with (pred N); apply Nat.le_pred_l.
  apply sum_eq; intros.
  replace (i + 0)%nat with i; [ reflexivity | trivial ].
  apply Nat.succ_lt_mono.
  replace (S (pred N)) with N.
  apply Nat.lt_le_trans with 2%nat; [ apply Nat.lt_succ_diag_r | assumption ].
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  inversion H1.
  left; reflexivity.
  right; apply le_n_S; assumption.
  simpl.
  replace (S (pred N)) with N.
  reflexivity.
  symmetry; apply Nat.lt_succ_pred with 0%nat; assumption.
  simpl.
  cut ((N - pred N)%nat = 1%nat).
  intro; rewrite H2; reflexivity.
  rewrite <- Nat.sub_1_r.
  apply INR_eq; repeat rewrite minus_INR.
  simpl; ring.
  apply Nat.le_succ_l; assumption.
  rewrite Nat.sub_1_r; apply Nat.le_pred_l.
  simpl; apply Nat.lt_succ_pred with 0%nat; assumption.
  inversion H.
  left; reflexivity.
  right; apply Nat.lt_le_trans with 1%nat; [ apply Nat.lt_succ_diag_r | exact H1 ].
Qed.
