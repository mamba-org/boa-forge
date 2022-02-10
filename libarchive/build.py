from bitfurnace.autotools import Autotools

class Recipe(Autotools):

	def get_configure_args(self):
		configure_args = []

		if features.static:
			configure_args += ['--enable-static', '--disable-shared']
		else:
			configure_args += ['--disable-static', '--enable-shared']

		def add_feature(feat, opt):
			if feat:
				configure_args.append(f'--with-{opt}')
			else:
				configure_args.append(f'--without-{opt}')

		if target_platform.startswith('osx'):
			configure_args += ['--with-iconv']
		else:
			configure_args += ['--without-iconv']
			if features.zstd:
				self.ldflags += ['-pthread']

		add_feature(features.bzip2, 'bz2lib')
		add_feature(features.lz4, 'lz4')
		add_feature(features.xz, 'lzma')
		add_feature(features.lzo, 'lzo2')
		add_feature(features.zstd, 'zstd')
		add_feature(features.openssl, 'openssl')

		configure_args += [
			'--without-cng',
			'--without-nettle',
			'--without-expat',
		]

		return configure_args