#!/usr/bin/perl 
require "cgi-lib.pl";
&ReadParse;

$mailprog = '/usr/sbin/sendmail -t';

print &PrintHeader;
unless (-e $mailprog)
{
print <<"PrintTag";
<HTML><BODY>
<H3>Can't find $mailprog.</H3>
<P>There is a typo in the mail program path.</P>
</BODY></HTML>
PrintTag
exit(0);
}


print "<html><body>";

#verify that something has been typed in 'email' field.
if ($in{'email'} eq "") 
{
print <<"PrintTag";
<HTML><BODY>
<H3>Please provide an e-mail address</H3>
<P>We can't write back without one!</P>
</BODY></HTML>
PrintTag
exit(0);
}


#Confirmation Web Page
print <<"PrintTag";
<html><body>
<p>Dear <b>$in{'firstname'}</b>,<br>  <br>
Thanks for filling out our email list form. The information you've sent will only be used to send you information about Wine Cellar Los Gatos.<br><br>The Hauck Family<br>  Here is the information we'll receive:<br><br>
<br></p>
</body></html>
PrintTag

print "<p><b>Your e-mail address is:  </b>";
print "$in{'email'}</p>";
print "<p><b>Your first name is:  </b>";
print "$in{'firstname'}</p>";
print "<p><b>Your last name is:  </b>";
print "$in{'lastname'}</p>";

print "<p><b>Your zip code is:  </b>";
print "$in{'zip'}</p>";
print "<p><b>Your additional comments:  </b>";
print "$in{'comments'}</p>";

#end of program

#open mail program for message to employee
open (MAIL, "|$mailprog -t") || die "Can't open $mailprog\n";

#print message headers (to, from, subject, etc)
print MAIL "To: $in{'emp1'}\n";  
print MAIL "Reply-To: $in{'email'}\n";   
print MAIL "From: $in{'email'}\n";
print MAIL "Subject: Wine Cellar Email Addition\n\n";#create body of message
print MAIL << "PrintTag";
Mailing Address information from $in{'firstname'} $in{'lastname'} 
His/her E-mail Address:  $in{'email'}

His/her zip code is: $in{'zip'}
His/her additional comments/questions: $in{'comments'}

PrintTag

close(MAIL, "|$mailprog");

#open mail program for message to employee
open (MAIL, "|$mailprog -t") || die "Can't open $mailprog\n";

#print message headers (to, from, subject, etc)
print MAIL "To: $in{'emp2'}\n";  
print MAIL "Reply-To: $in{'email'}\n";   
print MAIL "From: $in{'email'}\n";
print MAIL "Subject: Wine Cellar Email Addition\n\n";
#create body of message
print MAIL << "PrintTag";$in{'firstname'}| $in{'lastname'}| $in{'zip'}| $in{'email'}| $in{'comments'}
PrintTag

close(MAIL, "|$mailprog");



#end of program   




