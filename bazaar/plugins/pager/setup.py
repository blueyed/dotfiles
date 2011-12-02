#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup

setup(name='bzr-pager',
      description='Bazaar Pager Plugin',
      keywords='plugin bzr pager less',
      version='0.1.0',
      url='https://launchpad.net/bzr-pager',
      license='GPL',
      author='Lukáš Lalinský',
      author_email='lalinsky@gmail.com',
      package_dir={'bzrlib.plugins.pager': '.'},
      packages=['bzrlib.plugins.pager'],
)
