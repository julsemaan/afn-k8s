
yamlfmt:
	find -type f -name '*.yaml' -exec bash -c "cat {} | ./tools/yamlfmt-wrapper > {}.tmp && mv {}.tmp {}" \;
