#!/usr/bin/env python 
import yaml

if __name__ == '__main__':
	with open('micromamba/recipe.yaml') as recipe_in:
		y = yaml.safe_load(recipe_in)

	y["source"][0] = {
		'git_url': 'https://github.com/mamba-org/mamba',
		'git_rev': 'master',
		'git_depth': 1
	}

	del y["context"]
	y["package"] = {
		'name': 'micromamba-nightly',
		'version': '{{ environ.get("NIGHTLY_VERSION") }}'
	}

	with open('micromamba/recipe.yaml', 'w') as recipe_out:
		recipe_out.write(yaml.dump(y))
