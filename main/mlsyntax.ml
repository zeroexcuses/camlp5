(* camlp5r *)
(* mlsyntax.ml *)
(* Copyright (c) INRIA 2007-2017 *)

value symbolchar =
  let list =
    ['!'; '$'; '%'; '&'; '*'; '+'; '-'; '.'; '/'; ':'; '<'; '='; '>'; '?';
     '@'; '^'; '|'; '~']
  in
  loop where rec loop s i =
    if i == String.length s then True
    else if List.mem s.[i] list then loop s (i + 1)
    else False
;

value dotsymbolchar_star = 
  let list = [ '!'; '$'; '%'; '&'; '*'; '+'; '-'; '/'; ':'; '='; '>'; '?';
               '@'; '^'; '|' ]
  in
  loop where rec loop s i =
    if i == String.length s then True
    else if List.mem s.[i] list then loop s (i + 1)
    else False
;

value kwdopchar =
  let list = [ '$'; '&'; '*'; '+'; '-'; '/'; '<'; '='; '>';
               '@'; '^'; '|' ]
  in
  fun s i -> 
    if i == String.length s then True
    else List.mem s.[i] list
;

value is_prefixop =
  let list = ['!'; '?'; '~'] in
  let excl = ["!="; "??"; "?!"] in
  fun x ->
    not (List.mem x excl) && String.length x >= 2 &&
    List.mem x.[0] list && symbolchar x 1
;

value is_infixop0 =
  let list = ['='; '<'; '>'; '|'; '&'; '$'] in
  let excl = ["<-"; "||"; "&&"] in
  fun x ->
    not (List.mem x excl) && (x = "$" || String.length x >= 2) &&
    List.mem x.[0] list && symbolchar x 1
;

value is_infixop1 =
  let list = ['@'; '^'] in
  fun x ->
    String.length x >= 2 && List.mem x.[0] list &&
    symbolchar x 1
;

value is_infixop2 =
  let list = ['+'; '-'] in
  fun x ->
    x <> "->" && String.length x >= 2 && List.mem x.[0] list &&
    symbolchar x 1
;

value is_infixop3 =
  let list = ['*'; '/'; '%'] in
  fun x ->
    String.length x >= 2 && List.mem x.[0] list &&
    symbolchar x 1
;

value is_infixop4 x =
  String.length x >= 3 && x.[0] == '*' && x.[1] == '*' &&
  symbolchar x 2
;

value is_hashop =
  let list = ['#'] in
  let excl = ["#"] in
  fun x ->
    not (List.mem x excl) && String.length x >= 2 &&
    List.mem x.[0] list && symbolchar x 1
;

value is_operator0 = do {
  let ht = Hashtbl.create 73 in
  let ct = Hashtbl.create 73 in
  List.iter (fun x -> Hashtbl.add ht x True)
    ["asr"; "land"; "lor"; "lsl"; "lsr"; "lxor"; "mod"; "or"];
  List.iter (fun x -> Hashtbl.add ct x True)
    ['!'; '&'; '*'; '+'; '-'; '/'; ':'; '<'; '='; '>'; '@'; '^'; '|'; '~';
     '?'; '%'; '.'; '$'];
  fun x ->
    try Hashtbl.find ht x with
    [ Not_found -> try Hashtbl.find ct x.[0] with _ -> False ]
};

value is_andop s =
  String.length s > 3 &&
  (String.sub s 0 3 = "and") &&
  kwdopchar s 3 &&
  dotsymbolchar_star s 4
;

value is_letop s =
  String.length s > 3 &&
  (String.sub s 0 3 = "let") &&
  kwdopchar s 3 &&
  dotsymbolchar_star s 4
;

value is_operator s =
  is_operator0 s || (is_hashop s)
;

value is_infix_operator op =
  is_operator op && match op.[0] with [ '!'| '?'| '~' -> False | _ -> True ]
;