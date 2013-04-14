package com.aj.strutsweb.user.bo.impl;

import java.util.List;

import com.aj.strutsweb.user.bo.UserBo;
import com.aj.strutsweb.user.dao.UserDAO;
import com.aj.strutsweb.user.model.User;

public class UserBoImpl implements UserBo {

    UserDAO userDAO;

    //DI via Spring
    public void setUserDAO(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    //call DAO to save user
    public void addUser(User user) {

        userDAO.addUser(user);

    }

    //call DAO to return users
    public List<User> listUser() {

        return userDAO.listUser();

    }

}
