grep "java.lang.Thread.State: RUNNABLE" -A 1 td4 | grep -v socket | grep -v receive | grep -v RUNNABLE | grep -v "\-\-"
