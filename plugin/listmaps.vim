" File:         listmaps.vim
" Author:       Antony Scriven <ad_scriven@postmaster.co.uk>
" Last Change:  2003-06-13
" Version:      1.2
" Description:  :Listmaps lists all mappings in all sourced files in a
"               separate buffer. Unfortunately also picks up some lines
"               that don't contain maps.
" Changes:      1       Initial upload
"               1.1     Accidental commenting of the first line fixed!
"               1.2     Searching for maps sped up (Charles E. Campbell).
"                       More incorrect matches pruned (Charles E. Campbell).
"                       Reading in of files sped up.
"                       Overall roughly a 4x speed increase.

if exists("loaded_listmaps") | finish | endif | let loaded_listmaps = 1

command! Listmaps :silent! call Listmaps()<CR>

fun! Listmaps()

        let saved_z = @z
        let saved_eventignore = &eventignore
        let saved_ignorecase = &ignorecase
        let saved_smartcase = &smartcase
        let saved_lazyredraw = &lazyredraw
        let saved_undolevels = &undolevels

        " Try to speed things up a little.
        set lazyredraw eventignore=all undolevels=-1

        set noignorecase nosmartcase 

        redir! @z
        silent! scriptnames
        redir END

        new
        setlocal noswapfile buftype=nofile nofoldenable
        0 put z
        g/^$/d
        let @z = saved_z
        %s/^/@#/
        " Read in each file below where it's name is listed.
        g/^/ normal! $:exe "read " . expand("<cfile>")
        " We will mark all lines that we want to keep with @. There should be
        " no lines in a VimL script that start with @. We will then
        " delete the ones we don't want later. This is much quicker than using
        " v/.../.
        " Many globals condensed into one for speed -- Charles E. Campbell.
        g/^@\@!.*\(^\|\s\+\)["']\=\(map!\=\|[nvoilc]m\%[ap]\|no\%[remap]\|[nv]n\%[oremap]!\=\|no\%[remap]!\=\|[oilc]no\%[remap]\)\>/ s/^/@/
        " Delete all remaining lines
        v/^@/ d
        " Remove markers from lines.
        %s/^@#//
        %s/^@\s*/        /
        " Remove some lines that we know won't be maps:
        " Comments
        g/^\s*"/ d
        " Syntax definintions -- Charles E. Campbell.
        g/^\s*\(syn\s\+keyword\|[ls]et\|call\s\)/ d
        " Add foldmarkers
        g/^\s*\d*: / s/$/ \{\{\{1
        " Restore settings etc.
        let &eventignore = saved_eventignore
        let &ignorecase = saved_ignorecase
        let &smartcase = saved_smartcase
        let &lazyredraw = saved_lazyredraw
        let &undolevels = saved_undolevels
        setf vim
        setlocal foldmarker={{{,}}}
        setlocal foldmethod=marker
        setlocal foldenable
        1
endfun

