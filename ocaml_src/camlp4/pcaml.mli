(* camlp4r *)
(***********************************************************************)
(*                                                                     *)
(*                             Camlp4                                  *)
(*                                                                     *)
(*                Daniel de Rauglaudre, INRIA Rocquencourt             *)
(*                                                                     *)
(*  Copyright 2007 Institut National de Recherche en Informatique et   *)
(*  Automatique.  Distributed only by permission.                      *)
(*                                                                     *)
(***********************************************************************)

(* This file has been generated by program: do not edit! *)

(** Language grammar, entries and printers.

   Hold variables to be set by language syntax extensions. Some of them
   are provided for quotations management. *)

val syntax_name : string ref;;

(** {6 Parsers} *)

val parse_interf :
  (char Stream.t -> (MLast.sig_item * MLast.loc) list * bool) ref;;
val parse_implem :
  (char Stream.t -> (MLast.str_item * MLast.loc) list * bool) ref;;
   (** Called when parsing an interface (mli file) or an implementation
       (ml file) to build the syntax tree; the returned list contains the
       phrases (signature items or structure items) and their locations;
       the boolean tells that the parser has encountered a directive; in
       this case, since the directive may change the syntax, the parsing
       stops, the directive is evaluated, and this function is called
       again.
       These functions are references, because they can be changed to
       use another technology than the Camlp4 extended grammars. By
       default, they use the grammars entries [implem] and [interf]
       defined below. *)

val gram : Grammar.g;;
   (** Grammar variable of the OCaml language *)

val interf : ((MLast.sig_item * MLast.loc) list * bool) Grammar.Entry.e;;
val implem : ((MLast.str_item * MLast.loc) list * bool) Grammar.Entry.e;;
val top_phrase : MLast.str_item option Grammar.Entry.e;;
val use_file : (MLast.str_item list * bool) Grammar.Entry.e;;
val module_type : MLast.module_type Grammar.Entry.e;;
val module_expr : MLast.module_expr Grammar.Entry.e;;
val sig_item : MLast.sig_item Grammar.Entry.e;;
val str_item : MLast.str_item Grammar.Entry.e;;
val expr : MLast.expr Grammar.Entry.e;;
val patt : MLast.patt Grammar.Entry.e;;
val ctyp : MLast.ctyp Grammar.Entry.e;;
val let_binding : (MLast.patt * MLast.expr) Grammar.Entry.e;;
val type_declaration : MLast.type_decl Grammar.Entry.e;;
val class_sig_item : MLast.class_sig_item Grammar.Entry.e;;
val class_str_item : MLast.class_str_item Grammar.Entry.e;;
val class_expr : MLast.class_expr Grammar.Entry.e;;
val class_type : MLast.class_type Grammar.Entry.e;;
   (** Some entries of the language, set by [pa_o.cmo] and [pa_r.cmo]. *)

val input_file : string ref;;
   (** The file currently being parsed. *)
val output_file : string option ref;;
   (** The output file, stdout if None (default) *)
val report_error : exn -> unit;;
   (** Prints an error message, using the module [Format]. *)
val quotation_dump_file : string option ref;;
   (** [quotation_dump_file] optionally tells the compiler to dump the
       result of an expander if this result is syntactically incorrect.
       If [None] (default), this result is not dumped. If [Some fname], the
       result is dumped in the file [fname]. *)
val version : string;;
   (** The current version of Camlp4. *)
val add_option : string -> Arg.spec -> string -> unit;;
   (** Add an option to the command line options. *)
val no_constructors_arity : bool ref;;
   (** [True]: dont generate constructor arity. *)

val sync : (char Stream.t -> unit) ref;;

val handle_expr_quotation : MLast.loc -> string * string -> MLast.expr;;
val handle_patt_quotation : MLast.loc -> string * string -> MLast.patt;;

val expr_reloc : (MLast.loc -> MLast.loc) -> int -> MLast.expr -> MLast.expr;;
val patt_reloc : (MLast.loc -> MLast.loc) -> int -> MLast.patt -> MLast.patt;;

(** To possibly rename identifiers; parsers may call this function
    when generating their identifiers; default = identity *)
val rename_id : (string -> string) ref;;

(** Allow user to catch exceptions in quotations *)
type err_ctx =
    Finding
  | Expanding
  | ParsingResult of Stdpp.location * string
;;
exception Qerror of string * err_ctx * exn;;

(** {6 Printers} *)

val print_interf : ((MLast.sig_item * MLast.loc) list -> unit) ref;;
val print_implem : ((MLast.str_item * MLast.loc) list -> unit) ref;;
   (** Some printers, set by [pr_dump.cmo], [pr_o.cmo] and [pr_r.cmo]. *)

module NewPrinter :
  sig
    type 'a printer_t =
      { mutable pr_fun : string -> 'a pr_fun;
        mutable pr_levels : 'a pr_level list }
    and 'a pr_level = { pr_label : string; mutable pr_rules : 'a pr_rule }
    and 'a pr_rule =
      ('a, ('a pr_fun -> 'a pr_fun -> int -> string -> string -> string))
       Extfun.t
    and 'a pr_fun = int -> string -> 'a -> string -> string
    ;;
    val printer : 'a -> string -> 'b printer_t;;
    val pr_expr : MLast.expr printer_t;;
    val pr_patt : MLast.patt printer_t;;
    val pr_ctyp : MLast.ctyp printer_t;;
    val pr_str_item : MLast.str_item printer_t;;
    val pr_sig_item : MLast.sig_item printer_t;;
    val pr_module_expr : MLast.module_expr printer_t;;
    val pr_module_type : MLast.module_type printer_t;;
    val pr_class_sig_item : MLast.class_sig_item printer_t;;
    val pr_class_str_item : MLast.class_str_item printer_t;;
    val pr_class_type : MLast.class_type printer_t;;
    val pr_class_expr : MLast.class_expr printer_t;;
    val find_pr_level : string -> 'a pr_level list -> 'a pr_level;;
  end
;;

module Printer :
  sig
    open Spretty;;
    type 'a printer_t =
      { mutable pr_fun : string -> 'a -> string -> kont -> pretty;
        mutable pr_levels : 'a pr_level list }
    and 'a pr_level =
      { pr_label : string;
        pr_box : 'a -> pretty Stream.t -> pretty;
        mutable pr_rules : 'a pr_rule }
    and 'a pr_rule =
      ('a, ('a curr -> 'a next -> string -> kont -> pretty Stream.t)) Extfun.t
    and 'a curr = 'a -> string -> kont -> pretty Stream.t
    and 'a next = 'a -> string -> kont -> pretty
    and kont = pretty Stream.t
    ;;
    val pr_sig_item : MLast.sig_item printer_t;;
    val pr_str_item : MLast.str_item printer_t;;
    val pr_module_type : MLast.module_type printer_t;;
    val pr_module_expr : MLast.module_expr printer_t;;
    val pr_expr : MLast.expr printer_t;;
    val pr_patt : MLast.patt printer_t;;
    val pr_ctyp : MLast.ctyp printer_t;;
    val pr_class_sig_item : MLast.class_sig_item printer_t;;
    val pr_class_str_item : MLast.class_str_item printer_t;;
    val pr_class_type : MLast.class_type printer_t;;
    val pr_class_expr : MLast.class_expr printer_t;;
    val pr_expr_fun_args :
      (MLast.expr, (MLast.patt list * MLast.expr)) Extfun.t ref;;
    val find_pr_level : string -> 'a pr_level list -> 'a pr_level;;
    val top_printer : 'a printer_t -> 'a -> unit;;
    val string_of : 'a printer_t -> 'a -> string;;
    val inter_phrases : string option ref;;
  end
;;

(** {6 Directives} *)

type directive_fun = MLast.expr option -> unit;;
val add_directive : string -> directive_fun -> unit;;
val find_directive : string -> directive_fun;;

(**/**)

(* for system use *)

val warning : (Token.location -> string -> unit) ref;;
val expr_eoi : MLast.expr Grammar.Entry.e;;
val patt_eoi : MLast.patt Grammar.Entry.e;;
val arg_spec_list : unit -> (string * Arg.spec * string) list;;
