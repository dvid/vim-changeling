" Vim plugin file - changeling
" URL: https://github.com/dvid/changeling
" Aurhor: dvid < dvid_pp [a] yahoo - com >
" Last Change:  2016 May 05
" Version: ϡ

" @TODO Diff two buffers
" @TODO Follow line number over windows while moving in a file
" @TODO Version all saved buffers states to allow diffs to the actual file
" @TODO git edit in split mode to count and update line numbers
" @TODO prevent closing buffer with <D-w> or even <D-q>

" Allows symlinks to be expanded to the real file
function! GetPathofFile()
	let s:current_file_path = fnamemodify(resolve(expand('%:p')), ':h')
endfunction

" Run git diff in terminal
function! OpenSplit(bytecode)

        " Parse split list and look if splitted buffer already exists
        " from previous call and :bd on it before opening another one
        let s:bufNr = bufnr("$")
        while s:bufNr > 0
            if buflisted(s:bufNr)
                if (matchstr(bufname(s:bufNr), ".diff$") == ".diff")
                    if getbufvar(s:bufNr, '&modified') == 0
                        execute "bd ".s:bufNr
                    endif
                endif
            endif
            let s:bufNr = s:bufNr-1
        endwhile

        " Open a new split and set it up.
        vsplit %.diff
        normal! ggdG
        setlocal noswapfile buftype=nofile
        set filetype=on filetype=enabled syntax=diff

        " Insert the bytecode.
        call append(0, split(a:bytecode, '\v\n'))

endfunction

" If current file has been modified save buffer to blobfile and
" execute a git diff on it compared with last saved file state.
" File doesn't need to be in a git repo as the two files to compare
" are passed as argument.
function! IsModified()

   if &modified

		" Define current file and its buffer state
        let openfile = resolve(expand("%:p"))
        let blobfile = openfile . ".blob"

        " Write BufferState in blob file and delete it after cmd
		execute 'w' fnameescape(blobfile)
		let bytecode = system("git diff --no-index " . openfile . " " . blobfile)
       	execute "!" . "rm " . blobfile

        " create split
		call OpenSplit(bytecode)

    else
      echom "No Edit!"
    endif

endfunction

" Run git diff in terminal
function! ShowDiff()
    silent !clear
    execute "!" . "git diff " . expand("%:p")
endfunction

" Git diff from VCS for actual file in a vertical split
function! ShowGitDiff()

	" Get path of active buffer
    call GetPathofFile()

    " Get the diff.
    let bytecode = system("cd " . s:current_file_path . " && " . "git diff " . expand("%:t"))

    " Create split
    call OpenSplit(bytecode)

endfunction
