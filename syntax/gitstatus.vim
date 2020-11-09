" Vim syntax file
" Language: Git status
" Maintainer: Cedric M'Passi
" Latest Revision: 10 November 2020

syn case match

if exists("b:current_syntax")
  finish
endif

syn region 	gitstatusStaged start=/^\s*Modifications qui seront validées :$/ end=/^\s*$/ fold transparent contains=gitstatusStagedFile
syn match 	gitstatusStagedFile '\t.*' contained

syn region 	gitstatusModification start=/\s*Modifications qui ne seront pas validées :$/ end=/^\s*$/ fold transparent contains=gitstatusModificationFile
syn match 	gitstatusModificationFile '\t.*' contained

syn region  gitstatusUntracked start=/^\s*Fichiers non suivis:$/ end=/^$/ fold transparent contains=gitstatusUntrackedFile
syn match   gitstatusUntrackedFile  '\t\f*' contained

hi def link gitstatusStagedFile DiffAdd

hi def link gitstatusUntrackedFile DiffDelete

hi def link gitstatusModificationFile DiffChange

let b:current_syntax = "gitstatus"
