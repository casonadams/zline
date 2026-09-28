0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
source "${0:h}/zline.zsh"
zline preset powerline --transient
zline init
