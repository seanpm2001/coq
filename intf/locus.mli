(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, *   INRIA - CNRS - LIX - LRI - PPS - Copyright 1999-2010     *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

open Names
open Misctypes

(** Locus : positions in hypotheses and goals *)

(** {6 Occurrences} *)

type 'a occurrences_gen =
  | AllOccurrences
  | AllOccurrencesBut of 'a list (** non-empty *)
  | NoOccurrences
  | OnlyOccurrences of 'a list (** non-empty *)

type occurrences_expr = (int or_var) occurrences_gen
type 'a with_occurrences = occurrences_expr * 'a

type occurrences = int occurrences_gen


(** {6 Locations}

  Selecting the occurrences in body (if any), in type, or in both *)

type hyp_location_flag = InHyp | InHypTypeOnly | InHypValueOnly


(** {6 Abstract clauses expressions}

  A [clause_expr] (and its instance [clause]) denotes occurrences and
  hypotheses in a goal in an abstract way; in particular, it can refer
  to the set of all hypotheses independently of the effective contents
  of the current goal

  Concerning the field [onhyps]:
   - [None] means *on every hypothesis*
   - [Some l] means on hypothesis belonging to l *)

type 'a hyp_location_expr = 'a with_occurrences * hyp_location_flag

type 'id clause_expr =
  { onhyps : 'id hyp_location_expr list option;
    concl_occs : occurrences_expr }

type clause = identifier clause_expr


(** {6 Concrete view of occurrence clauses} *)

(** [clause_atom] refers either to an hypothesis location (i.e. an
   hypothesis with occurrences and a position, in body if any, in type
   or in both) or to some occurrences of the conclusion *)

type clause_atom =
  | OnHyp of identifier * occurrences_expr * hyp_location_flag
  | OnConcl of occurrences_expr

(** A [concrete_clause] is an effective collection of occurrences
    in the hypotheses and the conclusion *)

type concrete_clause = clause_atom list


(** {6 A weaker form of clause with no mention of occurrences} *)

(** A [hyp_location] is an hypothesis together with a location *)

type hyp_location = identifier * hyp_location_flag

(** A [goal_location] is either an hypothesis (together with a location)
    or the conclusion (represented by None) *)

type goal_location = hyp_location option


(** {6 Simple clauses, without occurrences nor location} *)

(** A [simple_clause] is a set of hypotheses, possibly extended with
   the conclusion (conclusion is represented by None) *)

type simple_clause = identifier option list
