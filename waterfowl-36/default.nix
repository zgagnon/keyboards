{qmk_source, pkgs, ...}:
with pkgs;
let
pname = "waterfowl-36";
version = "0.0.1";
buildPath = "qmk/keyboards/waterfowl";
in pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = ./.;
  buildInputs = with pkgs; [
    qmk_source
    qmk
    git
    emacs
    nix
  ];
  buildPhase = ''
emacs --batch -l org --eval '(org-babel-tangle-file "layout.org")'



workdir=$TMPDIR

cp -r ${qmk_source} $workdir/qmk
chmod -R +w $workdir/qmk
ls $workdir/qmk/keyboards/waterfowl/keymaps >> ls.txt
mkdir -p $workdir/qmk/keyboards/waterfowl/keymaps/zgagnon
cp keymap.c "$workdir"/qmk/keyboards/waterfowl/keymaps/zgagnon
cp rules.mk "$workdir"/qmk/keyboards/waterfowl
cp waterfowl.c "$workdir"/qmk/keyboards/waterfowl

(
  unset NIX_TARGET_CFLAGS_COMPILE
  cd $workdir/qmk
nix-shell --run "qmk compile -kb waterfowl -km zgagnon"

)

cp $workdir/qmk/waterfowl_zgagnon.hex ..


  '';
  installPhase = ''
    mkdir -p $out/bin
cp waterfowl_zgagnon.hex $out
mv ls.txt $out
  '';
}
