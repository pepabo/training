#!/usr/bin/env node

const childProcess = require('child_process')
const program = require('commander')
const fs = require('fs-extra')
const path = require('path')
const tempy = require('tempy')

program
  .option('--no-app', 'start project without tutorial application')

program.parse(process.argv)

const tempdir = tempy.directory()

console.log('cloning frontend-training repository to temp directory')
const cloneRes = childProcess.spawnSync('git', [
  'clone',
  'https://github.com/pepabo/frontend-training.git',
  tempdir
])
if (cloneRes.error) {
  throw cloneRes.error
}

const destdir = path.join(process.cwd(), 'frontend-training')
if (fs.existsSync(destdir)) {
  throw new Error(`${destdir} exists`)
}
console.log(`copying project skeleton to ${destdir}`)
fs.copySync(path.join(tempdir, 'skeleton'), destdir)

if (program.app) {
  console.log('appending sample application')
  fs.copySync(path.join(tempdir, 'app_start'), path.join(destdir, 'sample_app'))
}

console.log('executing git init')
const initRes = childProcess.spawnSync('git', ['init'], { cwd: destdir })
if (initRes.error) {
  throw initRes.error
}
