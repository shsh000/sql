package common;

import java.io.FileReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

public class DAO {
	
 
	//String  = "db.properties";
	Properties pro = new Properties();

	String jdbcDriver = null;
	String jdbcUrl = null;
	String jdbcId = null;
	String jdbcPw = null;
	protected Connection conn = null;
	protected ResultSet rs = null;
	protected PreparedStatement pstmt = null;
	protected Statement stmt = null;
	protected CallableStatement cstmt = null;
	public void conn() {
		getProperties();
		try {
			// 1. 드라이버 로딩 : 메모리로
			Class.forName(jdbcDriver);
			// 2. DB 연결
			conn = DriverManager.getConnection(jdbcUrl, jdbcId, jdbcPw);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private void getProperties() {
		try {
			FileReader resource = new FileReader("src/config/db.properties");
			pro.load(resource);
			jdbcDriver = pro.getProperty("driver");
			jdbcUrl = pro.getProperty("url");
			jdbcId = pro.getProperty("user");
			jdbcPw = pro.getProperty("password");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void disconnect() {
		try {
			if (rs != null) {
				rs.close();
			}
			if (stmt != null) {
				stmt.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
			if (conn != null) {
				conn.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
