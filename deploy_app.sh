#!/bin/bash
git add .
git commit -m "incremental fix"
git push origin master
git push heroku
