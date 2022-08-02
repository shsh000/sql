package jdbc.member;

import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import common.DAO;

public class Management extends DAO{
	
	Scanner sc = new Scanner(System.in);
	
	public Management() {
		run();
	}
	
	private void run() {
		while(true) {
			System.out.println("하고 싶은 업무를 선택하세요.");
			System.out.println("1. 전체 조회 2. 개별 조회 3. 회원 등록 4. 회원 수정 5. 회원 삭제 99. 종료");
			System.out.print(">");
			int menuNo = Integer.parseInt(sc.nextLine());
			if(menuNo == 1) {
				List<Member> mList = getMemberList();
				for(int i = 0; i<mList.size(); i++) {
					System.out.println(mList.get(i).toString());			
				}
			}
			else if(menuNo == 2) {
				System.out.println("회원 ID>");
				Member member = getMember(sc.nextLine());
				System.out.println(member.toString());
			}
			else if(menuNo == 3) {
				Member member = new Member();
				System.out.println("정보 입력하세요");
				System.out.println("이름>");
				member.setName(sc.nextLine());
				System.out.println("아디>");
				member.setId(Integer.parseInt(sc.nextLine()));
				System.out.println("비번>");
				member.setPw(sc.nextLine());
				int result = insertMember(member);
				System.out.println(result + "건이 입력되었습니다.");
			}
			else if(menuNo == 4) {
				Member member = new Member();
				System.out.println("정보 입력하세요");
				System.out.println("비번>");
				member.setPw(sc.nextLine());
				System.out.println("아디>");
				member.setId(Integer.parseInt(sc.nextLine()));
				int result = updateMember(member);
				System.out.println(result + "건이 수정되었습니다.");
			}
			else if(menuNo == 5) {
				Member member = new Member();
				System.out.println("정보 입력하세요");
				System.out.println("아디>");
				member.setId(Integer.parseInt(sc.nextLine()));
				int result = deleteMember(member);
				System.out.println(result + "건이 삭제되었습니다.");
			}else {
				System.out.println("프로그램 종료");
				break;
			}
		}
	}
	
	
	
	private List<Member> getMemberList() {
		List<Member> list = new ArrayList<Member>();
		try {
			Member member = null;
			conn();
			String sql = "select * from member";
			stmt = conn.createStatement();
			rs = stmt.executeQuery(sql);
			while(rs.next()) {
				member = new Member();
				member.setId(rs.getInt("id"));
				member.setName(rs.getString("name"));
				member.setPw(rs.getString("pw"));
				list.add(member);
			}
			
		}catch(SQLException e) {
			e.printStackTrace();
		}finally {
			disconnect();
		}
		return list;
	}

	private Member getMember(String memberId) {
		Member member = null;
		try {
			conn();
			String sql = "select * from member where id = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, memberId);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				member = new Member();
				member.setId(rs.getInt("id"));
				member.setName(rs.getString("name"));
				member.setPw(rs.getString("pw"));
			}
		}catch(SQLException e) {
			e.printStackTrace();
		}finally {
			disconnect();
		}
		return member;
	}
	
	private int insertMember(Member member) {
		int result = 0;
		try {
			conn();
			//1. CallableStatement 객체 추가
			//protected CallableStatement cstmt = null;
			//2. 쿼리 작성
			// String sql = "{call out_proc(?,?)}";
			//3. conn.prepareCall(sql) 입력 
			//cstmt = conn.prepareCall(sql);
			//4. 매개변수 IN일 경우
			//prepareStatement에서 데이터 넣듯이 해주면 됨.
			//5. 매개변수 OUT일 경우
			//호출 전 -> cstmt.registerOutParameter(1, Types.VARCHAR);
			//호출 후 -> cstmt.getString(1);
			
			// 매개변수 IN일 경우
//			String sql = "{call setMember(?,?,?)}";
//			//String sql = "insert into member values (?,?,?)";
//			cstmt = conn.prepareCall(sql);
//			cstmt.setInt(1, member.getId());
//			cstmt.setString(2, member.getPw());
//			cstmt.setString(3, member.getName());
//			result = cstmt.executeUpdate();
			
			
			// 매개변수 OUT일 경우
			String sql = "{call out_proc(?,?)}";
			cstmt = conn.prepareCall(sql);
			cstmt.registerOutParameter(1, Types.VARCHAR);
			cstmt.registerOutParameter(2, Types.INTEGER);
			result = cstmt.executeUpdate();

			System.out.println(cstmt.getString(1));
			System.out.println(cstmt.getInt(2));
		}catch(SQLException e) {
			e.printStackTrace();
		}finally {
			disconnect();
		}
		return result;
	}
	
	private int deleteMember(Member member) {
		int result = 0;
		try {
			conn();
			String sql = "delete from member where id = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, member.getId());
			result = pstmt.executeUpdate();
		}catch(SQLException e) {
			e.printStackTrace();
		}finally {
			disconnect();
		}
		return result;
	}
	
	private int updateMember(Member member) {
		int result = 0;
		try {
			conn();
			String sql = "update member set pw = ? where id =?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, member.getPw());
			//pstmt.setString(2, member.getId());
		}catch(SQLException e) {
			e.printStackTrace();
		}finally {
			disconnect();
		}
		return result;
	}
	
	
}
