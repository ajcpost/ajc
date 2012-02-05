<%@ taglib prefix="s" uri="/struts-tags" %>
<html>
<head>
</head>
 
<body>
<h1>Struts 2 + Spring + Hibernate integration example</h1>

<h2>Add User</h2>
<s:form action="addUserAction" >
  <s:textfield name="name" label="Name" value="" />
  <s:textarea name="address" label="Address" value="" cols="50" rows="5" />
  <s:submit />
</s:form>

<h2>All Users</h2>

<s:if test="userList != NULL">
<s:if test="userList.size() > 0">
<table border="1px" cellpadding="8px">
	<tr>
		<th>User Id</th>
		<th>Name</th>
		<th>Address</th>
		<th>Created Date</th>
	</tr>
	<s:iterator value="userList" status="userStatus">
		<tr>
			<td><s:property value="userId" /></td>
			<td><s:property value="name" /></td>
			<td><s:property value="address" /></td>
			<td><s:date name="createdDate" format="dd/MM/yyyy" /></td>
		</tr>
	</s:iterator>
</table>
</s:if>
</s:if>
<br/>
<br/>

</body>
</html>
