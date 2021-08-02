#!/bin/bash

export CLOUDFLARE_EMAIL="$(lpass show --field=id Lab/Cloudflare)"
export CLOUDFLARE_TOKEN="$(lpass show --field=key Lab/Cloudflare)"