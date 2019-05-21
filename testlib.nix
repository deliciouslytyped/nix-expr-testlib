#TODO indentation is totally messed up
{lib}:
 rec {
  #TODO failed test backtrace
  #TODO NOTE tryEval is basically useless right now, it fails to catch most errors
  runTest = test: builtins.tryEval test;

  testReport = tabcount: name: ignored: result:
    #TODO find a lib function
    let repstr = str: counter: if counter > 0 then str + (repstr str (counter - 1)) else ""; in
    if builtins.elem name ignored
      then "${name}: ${repstr "\t" tabcount} ignored. ;_;" 
    else if result.success
      then "${name}: ${repstr "\t" tabcount} success Yay! =^.^="
    else "ONOES. (ノಠ益ಠ)ノ彡${name} failed.";

  runAll = tests: ignored:
    let
      maxname = lib.foldr lib.max 0 (lib.mapAttrsToList (n: v: builtins.stringLength n) tests);
      mpad = (((maxname + 7) / 8) * 8) - maxname;
      npad = name: ((((builtins.stringLength name) + 7) / 8) * 8) - (builtins.stringLength name); #TODO simplify
#      tabcount = name: (((maxname - 2 * (padded_name name) + (builtins.stringLength name)) / 8) + 1);
      tabcount = name: ((maxname + mpad - (builtins.stringLength name) - (npad name)) / 8) + 1;
    in
    "\n" + (lib.concatStringsSep "\n" (
      lib.mapAttrsToList
        (name: test: testReport (tabcount name) name ignored (runTest test))
        tests
        ));

  # see https://github.com/NixOS/nix/blob/bb6e6923f25841874b6a915d234d884ddd4c92dd/src/libexpr/eval.cc#L1706
  #  and https://github.com/NixOS/nix/blob/bb6e6923f25841874b6a915d234d884ddd4c92dd/src/libexpr/eval.cc#L1560
  #TODO ...can't check equality on functions...which was probabyl the whole point
  #TODO this is a mess
  drvSetEq = a: b: #Hack to compare drv+Sets
    let
      drvSet = a: (a // { type = "set";});
      #res1 = drvSet a == drvSet b;
      res1 = builtins.mapAttrs (n: v: a.${n} == b.${n}) a;
      res2 = lib.filterAttrs (n: v: (n != "nixpkgs") && (v == false) &&
        (!((builtins.typeOf a.${n} == "lambda") && (builtins.typeOf b.${n}) == "lambda")) ) res1;
      res3 = (builtins.length (builtins.attrNames res2)) == 0;
    in
      res3;
}
