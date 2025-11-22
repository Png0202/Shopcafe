package com.cafe.util;

import java.sql.Connection;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class DBConnection {

    private static DataSource dataSource;

    static {
        try {
            Context ctx = new InitialContext();
            // Tên JNDI phải khớp với context.xml
            dataSource = (DataSource) ctx.lookup("java:/comp/env/jdbc/cafeshop");
        } catch (NamingException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
}
