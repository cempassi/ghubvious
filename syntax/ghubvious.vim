" Vim syntax file
" Language: Git status
" Maintainer: Cedric M'Passi
" Latest Revision: 10 November 2020

syn case match

if exists("b:current_syntax")
  finish
endif

syn region 	ghubviousStaged start=/^\s*Modifications qui seront validées :$/ end=/^\s*$/ fold transparent contains=ghubviousStagedFile
syn region 	ghubviousStaged start=/^\s*Changes to be committed:$/ end=/^\s*$/ fold transparent contains=ghubviousStagedFile
syn match 	ghubviousStagedFile '\t.*' contained

syn region 	ghubviousModification start=/\s*Modifications qui ne seront pas validées :$/ end=/^\s*$/ fold transparent contains=ghubviousModificationFile
syn region 	ghubviousModification start=/\s*Changes not staged for commit:$/ end=/^\s*$/ fold transparent contains=ghubviousModificationFile
syn match 	ghubviousModificationFile '\t.*' contained

syn region  ghubviousUntracked start=/^\s*Fichiers non suivis:$/ end=/^$/ fold transparent contains=ghubviousUntrackedFile
syn region  ghubviousUntracked start=/^\s*Untracked files:$/ end=/^$/ fold transparent contains=ghubviousUntrackedFile
syn match   ghubviousUntrackedFile  '\t\f*' contained

hi def link ghubviousStagedFile DiffAdd

hi def link ghubviousUntrackedFile DiffDelete

hi def link ghubviousModificationFile DiffChange

let b:current_syntax = "ghubvious"
