" Format all -> find -type f -name '*.yaml' -exec bash -c "cat {} | ./yq-wrapper" > {}.tmp && mv {}.tmp {}" \;
autocmd FileType yaml autocmd BufWritePre <buffer> call Preserve("%!yq")
