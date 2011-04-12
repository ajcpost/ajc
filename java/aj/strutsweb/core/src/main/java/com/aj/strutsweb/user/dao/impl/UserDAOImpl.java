package com.aj.strutsweb.user.dao.impl;

import java.util.List;

import org.springframework.orm.hibernate3.support.HibernateDaoSupport;

import com.aj.strutsweb.user.dao.UserDAO;
import com.aj.strutsweb.user.model.User;
 
public class UserDAOImpl extends HibernateDaoSupport implements UserDAO{
	
	//add the user
	public void addUser(User user){
		
		getHibernateTemplate().save(user);
		
	}
	
	//return all the users in list
	public List<User> listUser(){
		
		return getHibernateTemplate().find("from User");
		
	}
	
}
