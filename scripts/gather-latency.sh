#!/bin/sh

export POD=$1
# Cms
cat `find . -name "u*" -print` | grep -vi forecast | grep -vi research | grep -vi accountservice | grep -vi bulk | cut -d ":" -f3 -f5 -f8 | sed "s/^ *//g" | sed "s/ \{1,\}/ /g" | sed "s/( /(/g" | cut -d " " -f1 -f5 -f7 | awk '{print ENVIRON["POD"] " Cms " $0}'

# Forecast
cat `find . -name "u*" -print` | grep -i forecast | cut -d ":" -f3 -f5 -f8 | sed "s/^ *//g" | sed "s/ \{1,\}/ /g" | sed "s/( /(/g" | cut -d " " -f1 -f5 -f7 | awk '{print ENVIRON["POD"] " Fcst " $0}'

# Krs
cat `find . -name "u*" -print` | grep -i research | cut -d ":" -f3 -f5 -f8 | sed "s/^ *//g" | sed "s/ \{1,\}/ /g" | sed "s/( /(/g" | cut -d " " -f1 -f5 -f7 | awk '{print ENVIRON["POD"] " Krs " $0}'

# Account service
cat `find . -name "u*" -print` | grep -i accountservice | cut -d ":" -f3 -f5 -f8 | sed "s/^ *//g" | sed "s/ \{1,\}/ /g" | sed "s/( /(/g" | cut -d " " -f1 -f5 -f7 | awk '{print ENVIRON["POD"] " As " $0}'

# Bulk
cat `find . -name "u*" -print` | grep -i bulk | cut -d ":" -f3 -f5 -f8 | sed "s/^ *//g" | sed "s/ \{1,\}/ /g" | sed "s/( /(/g" | cut -d " " -f1 -f5 -f7 | awk '{print ENVIRON["POD"] " Blk " $0}'
