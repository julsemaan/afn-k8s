autocmd FileType yaml autocmd BufWritePre <buffer> call Preserve("%!yq")
