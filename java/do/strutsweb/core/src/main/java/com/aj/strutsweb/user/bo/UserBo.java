package com.aj.strutsweb.user.bo;

import java.util.List;

import com.aj.strutsweb.user.model.User;
 
public interface UserBo{
	
	void addUser(User user);
	
	List<User> listUser();
	
}
