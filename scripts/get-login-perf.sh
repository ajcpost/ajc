#!/bin/sh
## get all loginPage, login, logout related perf logs
## Open in excel, sort on time

#login page
#grep "ariba.collaborate.appui.DirectAction" perf-UI* | grep default | grep "ariba/ui/aribaweb/core/AWRedirect"
#grep "ariba.ui.sso.SSOActions"  perf-UI* | grep \"loginPage\", | grep "ariba/ui/sso/SSOMain"

#login
grep "ariba.ui.sso.SSOActions" perf-UI* | grep \"login\", | grep "ariba/ui/aribaweb/core/AWRedirect"
grep "ariba.ui.sso.SSOActions" perf-UI* | grep \"loginRedirect\",
grep "ariba/dashboard/component/DashboardMain" perf-UI* | grep \"refresh\",
grep dashboard perf-UI* | grep view | grep Portlet

#logout
#grep "ariba.ui.sso.SSOActions" perf-UI* | grep \"logout\",
#grep "ariba.ui.sso.SSOActions" perf-UI* | grep \"clientLogout\",
#grep "ariba.ui.sso.SSOActions" perf-UI* | grep \"logoutAck\",
