(* camlp5r *)
(* $Id: pa_mktest.ml,v 1.5 2010/09/14 10:57:41 deraugla Exp $ *)

(*
   meta/camlp5r etc/pa_mktest.cmo etc/pr_r.cmo -flag D -impl main/mLast.mli
*)

#load "pa_extend.cmo";
#load "q_MLast.cmo";

open Versdep;

Pcaml.strict_mode.val := True;

value rec pfx short t =
  let t =
    match t with
    [ <:ctyp< Ploc.vala $t$ >> -> t
    | t -> t ]
  in
  match t with
  [ <:ctyp< loc >> -> if short then "l" else "loc"
  | <:ctyp< bool >> -> "b"
  | <:ctyp< class_expr >> -> "ce"
  | <:ctyp< class_sig_item >> -> "csi"
  | <:ctyp< class_str_item >> -> "csi"
  | <:ctyp< class_type >> -> "ct"
  | <:ctyp< expr >> -> "e"
  | <:ctyp< module_expr >> -> "me"
  | <:ctyp< module_type >> -> "mt"
  | <:ctyp< patt >> -> "p"
  | <:ctyp< poly_variant >> -> "pv"
  | <:ctyp< sig_item >> -> "si"
  | <:ctyp< str_item >> -> "si"
  | <:ctyp< string >> -> "s"
  | <:ctyp< ctyp >> -> "t"
  | <:ctyp< type_decl >> -> "td"
  | <:ctyp< type_var >> -> "tv"
  | <:ctyp< with_constr >> -> "wc"
  | <:ctyp< class_infos $t$ >> -> "ci" ^ pfx True t
  | <:ctyp< list $t$ >> -> "l" ^ pfx True t
  | <:ctyp< option $t$ >> -> pfx True t
  | <:ctyp< ($list:tl$) >> -> String.concat "" (List.map (pfx True) tl)
  | _ -> "x" ]
;

value prefix_of_type = pfx False;

value name_of_vars proj_t xl =
  let (rev_tnl, env) =
    List.fold_left
      (fun (rev_tnl, env) x ->
         let t = proj_t x in
         let pt = prefix_of_type t in
         let (n, env) =
           loop env where rec loop =
             fun
             [ [(n1, cnt1) :: env] ->
                 if n1 = pt then (cnt1, [(n1, cnt1 + 1) :: env])
                 else
                   let (n, env) = loop env in
                   (n, [(n1, cnt1) :: env])
             | [] -> (1, [(pt, 2)]) ]
         in
         ([(x, (pt, n)) :: rev_tnl], env))
       ([], []) xl
  in
  list_rev_map
    (fun (x, (pt, n)) ->
       let name =
         if List.assoc pt env = 2 then pt
         else pt ^ string_of_int n
       in
       (x, name))
    rev_tnl
;

value rec expr_list_of_type loc f n =
  fun
  [ <:ctyp< Ploc.vala $t$ >> ->
      expr_list_of_type loc (fun e -> f <:expr< Ploc.VaVal $e$ >>) n t @
      f <:expr< $lid:n$ >>
  | <:ctyp< bool >> ->
      f <:expr< True >> @
      f <:expr< False >> @
      f <:expr< $lid:n$ >>
  | <:ctyp< option $t$ >> ->
      f <:expr< None >> @
      expr_list_of_type loc (fun e -> f <:expr< Some $e$ >>) n t @
      f <:expr< $lid:n$ >>
  | _ ->
      f <:expr< $lid:n$ >> ]
;

value expr_of_cons_decl (loc, c, tl) =
  let tl = Pcaml.unvala tl in
  let tnl = name_of_vars (fun t -> t) tl in
  let c = Pcaml.unvala c in
  loop <:expr< MLast.$uid:c$ >> tnl where rec loop e1 =
    fun
    [ [(t, n) :: tnl] ->
        let f e2 = loop <:expr< $e1$ $e2$ >> tnl in
        expr_list_of_type loc f n t
    | [] -> [e1] ]
;

value expr_list_of_type_decl loc td =
  match td.MLast.tdDef with
  [ <:ctyp< [ $list:cdl$ ] >> ->
      List.fold_right (fun cd el -> expr_of_cons_decl cd @ el) cdl []
  | <:ctyp< { $list:ldl$ } >> ->
      let ldnl = name_of_vars (fun (loc, l, mf, t) -> t) ldl in
      let pell =
        loop ldnl where rec loop =
          fun
          [ [((loc, l, mf, t), n) :: ldnl] ->
              let p = <:patt< MLast.$lid:l$ >> in
              let pell = loop ldnl in
              let f e = List.map (fun pel -> [(p, e) :: pel]) pell in
              expr_list_of_type loc f n t
          | [] -> [[]] ]
      in
      List.map (fun pel -> <:expr< {$list:pel$} >>) pell
  | _ -> [<:expr< 0 >>] ]
;

value gen_ast loc tdl =
  match tdl with
  [ [{MLast.tdNam = <:vala< (_, <:vala< "ctyp" >>) >>} :: _] ->
      let ell = List.map (fun td -> expr_list_of_type_decl loc td) tdl in
      let el = List.flatten ell in
      let sil = List.map (fun e -> <:str_item< $exp:e$ >>) el in
      let sil = [<:str_item< begin_stuff >> :: sil] in
      let sil = sil @ [<:str_item< end_stuff >>] in
      <:str_item< declare $list:sil$ end >>
  | _ -> <:str_item< type $list:tdl$ >> ]
;

EXTEND
  Pcaml.str_item:
    [ [ "type"; tdl = LIST1 Pcaml.type_declaration SEP "and" ->
          gen_ast loc tdl ] ]
  ;
END;
