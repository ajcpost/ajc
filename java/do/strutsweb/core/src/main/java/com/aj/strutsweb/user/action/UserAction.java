package com.aj.strutsweb.user.action;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.aj.strutsweb.user.bo.UserBo;
import com.aj.strutsweb.user.model.User;
import com.opensymphony.xwork2.ModelDriven;
 
public class UserAction implements ModelDriven{

	User user = new User();
	List<User> userList = new ArrayList<User>();
	
	UserBo userBo;
	//DI via Spring
	public void setUserBo(UserBo userBo) {
		this.userBo = userBo;
	}

	public Object getModel() {
		return user;
	}
	
	public List<User> getUserList() {
		return userList;
	}

	public void setUserList(List<User> userList) {
		this.userList = userList;
	}

	//save user
	public String addUser() throws Exception{
		
		//save it
		user.setCreatedDate(new Date());
		userBo.addUser(user);
	 
		//reload the user list
		userList = null;
		userList = userBo.listUser();
		
		return "success";
	
	}
	
	//list all users
	public String listUser() throws Exception{
		
		userList = userBo.listUser();
		
		return "success";
	
	}
	
}
