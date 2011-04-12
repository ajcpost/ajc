package com.aj.strutsweb.user.dao;

import java.util.List;

import com.aj.strutsweb.user.model.User;
 
public interface UserDAO{
	
	void addUser(User user);
	
	List<User> listUser();
	
}
