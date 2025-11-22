# Sử dụng môi trường Tomcat có sẵn Java
FROM tomcat:9.0-jdk17-openjdk-slim

# Xóa ứng dụng mặc định của Tomcat cho nhẹ
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy file .war của bạn vào thư mục chạy web của Tomcat
# LƯU Ý: Bạn cần đổi tên file .war của bạn thành ROOT.war trước khi đẩy lên
COPY ROOT.war /usr/local/tomcat/webapps/ROOT.war

# Mở cổng 8080
EXPOSE 8080

# Chạy Tomcat
CMD ["catalina.sh", "run"]