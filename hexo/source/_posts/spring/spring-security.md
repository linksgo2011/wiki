---
title: Spring Security 基础
categories: Spring
toc: true
from: self
---

## 基本概念

Spring Security 主要解决用户的认证和授权问题，以及一些技术防护设施，例如 XSS、CSRF问题。

Spring Security 不仅仅解决权限和认证问题，还解决一些安全过滤，以及增加 HTTP 头部等能力。


## security 注册的 filter 

在 FilterComparator 中可以找到

```
	FilterComparator() {
		Step order = new Step(INITIAL_ORDER, ORDER_STEP);
		put(ChannelProcessingFilter.class, order.next());
		put(ConcurrentSessionFilter.class, order.next());
		put(WebAsyncManagerIntegrationFilter.class, order.next());
		put(SecurityContextPersistenceFilter.class, order.next());
		put(HeaderWriterFilter.class, order.next());
		put(CorsFilter.class, order.next());
		put(CsrfFilter.class, order.next());
		put(LogoutFilter.class, order.next());
		filterToOrder.put(
			"org.springframework.security.oauth2.client.web.OAuth2AuthorizationRequestRedirectFilter",
				order.next());
		put(X509AuthenticationFilter.class, order.next());
		put(AbstractPreAuthenticatedProcessingFilter.class, order.next());
		filterToOrder.put("org.springframework.security.cas.web.CasAuthenticationFilter",
				order.next());
		filterToOrder.put(
			"org.springframework.security.oauth2.client.web.OAuth2LoginAuthenticationFilter",
				order.next());
		put(UsernamePasswordAuthenticationFilter.class, order.next());
		put(ConcurrentSessionFilter.class, order.next());
		filterToOrder.put(
				"org.springframework.security.openid.OpenIDAuthenticationFilter", order.next());
		put(DefaultLoginPageGeneratingFilter.class, order.next());
		put(DefaultLogoutPageGeneratingFilter.class, order.next());
		put(ConcurrentSessionFilter.class, order.next());
		put(DigestAuthenticationFilter.class, order.next());
		filterToOrder.put(
				"org.springframework.security.oauth2.server.resource.web.BearerTokenAuthenticationFilter", order.next());
		put(BasicAuthenticationFilter.class, order.next());
		put(RequestCacheAwareFilter.class, order.next());
		put(SecurityContextHolderAwareRequestFilter.class, order.next());
		put(JaasApiIntegrationFilter.class, order.next());
		put(RememberMeAuthenticationFilter.class, order.next());
		put(AnonymousAuthenticationFilter.class, order.next());
		filterToOrder.put(
			"org.springframework.security.oauth2.client.web.OAuth2AuthorizationCodeGrantFilter",
				order.next());
		put(SessionManagementFilter.class, order.next());
		put(ExceptionTranslationFilter.class, order.next());
		put(FilterSecurityInterceptor.class, order.next());
		put(SwitchUserFilter.class, order.next());
	}
```

## HttpSecurity 配置规则说明

```
protected void configure(HttpSecurity http) throws Exception {
	http
		.authorizeRequests()                                                                
			.antMatchers("/resources/**", "/signup", "/about").permitAll()                  
			.antMatchers("/admin/**").hasRole("ADMIN")                                      
			.antMatchers("/db/**").access("hasRole('ADMIN') and hasRole('DBA')")            
			.anyRequest().authenticated()                                                   
			.and()
		// ...
		.formLogin();
}
```


- http.authorizeRequests()方法有多个子节点，每个macher按照他们的声明顺序执行。
- 我们指定任何用户都可以通过访问的多个URL模式。任何用户都可以访问URL以"/resources/", equals "/signup", 或者 "/about"开头的URL。
- 以 "/admin/" 开头的URL只能由拥有 "ROLE_ADMIN"角色的用户访问。请注意我们使用 hasRole 方法，没有使用 "ROLE_" 前缀.
- 任何以"/db/" 开头的URL需要用户同时具有 "ROLE_ADMIN" 和 "ROLE_DBA"。和上面一样我们的 hasRole 方法也没有使用 "ROLE_" 前缀.
- 尚未匹配的任何URL要求用户进行身份验证

## JDBC 验证

```
@Autowired
private DataSource dataSource;

@Autowired
public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
	auth
		.jdbcAuthentication()
			.dataSource(dataSource)
			.withDefaultSchema()
			.withUser("user").password("password").roles("USER").and()
			.withUser("admin").password("password").roles("USER", "ADMIN");
}

```


如果需要提供自己的验证器实现 AuthenticationProvider

```
@Bean
public SpringAuthenticationProvider springAuthenticationProvider() {
	return new SpringAuthenticationProvider();
}
```

## UserDetailsService

```
@Bean
public SpringDataUserDetailsService springDataUserDetailsService() {
	return new SpringDataUserDetailsService();
}
```

## 定义密码加密方式

```
@Bean
public BCryptPasswordEncoder passwordEncoder() {
	return new BCryptPasswordEncoder();
}

```


## 给方法添加权限检查 EnableGlobalMethodSecurity 


我们可以在任何使用@Configuration的实例上，使用@EnableGlobalMethodSecurity注解来启用基于注解的安全性。例如下面会启用Spring的@Secured注解。

```
@EnableGlobalMethodSecurity(securedEnabled = true)
public class MethodSecurityConfig {
// ...
}
```


## 使用 token 方式鉴权

![](./spring-security/spring-security-jwt-authentication-architecture-diagram.png)



参考资料 https://grokonez.com/spring-framework/spring-security/spring-boot-spring-security-jwt-authentication-architecture-tutorial



## 相关资料

- SpringSecurity原理剖析与权限系统设计 https://www.cnblogs.com/fanzhidongyzby/archive/2019/09/29/11610334.html
- Spring Security用户认证流程源码详解 https://blog.csdn.net/qq_37142346/article/details/80032336
- 中文文档 https://www.springcloud.cc/spring-security-zhcn.html#getting-starteda
- Config Spring Security for Restful API https://www.baeldung.com/securing-a-restful-web-service-with-spring-security
- https://spring.io/guides/gs/securing-web/