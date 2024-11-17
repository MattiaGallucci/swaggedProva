<%@page import="model.CommunityBean"%>
<%@page import="java.util.List"%>
<%@page import="model.PostBean"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	CommunityBean communityBean = (CommunityBean) request.getAttribute("community");

    // Recupera i dati dalla richiesta
    List<PostBean> posts = (List<PostBean>) request.getAttribute("posts");
    Boolean isLogged = (Boolean) session.getAttribute("logged");
    if (isLogged == null || !isLogged) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Community Posts</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        .community-name {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .community-description {
            font-size: 16px;
            color: #555;
        }
        .post-container {
            border: 1px solid #ddd;
            padding: 20px;
            margin-bottom: 20px;
            max-width: 600px;
            box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);
        }
        .post-image {
            width: 100%;
            height: auto;
        }
        .post-title {
            font-size: 24px;
            font-weight: bold;
        }
        .post-body {
            margin-top: 10px;
            font-size: 16px;
        }
        .post-info {
            font-size: 14px;
            color: #555;
        }
        .interaction-buttons button {
            margin-right: 5px;
            padding: 5px 10px;
            cursor: pointer;
            border: none;
            border-radius: 5px;
        }
        .like-button {
            background-color: #4CAF50;
            color: white;
        }
        .report-button {
            background-color: orange;
            color: white;
        }
        .delete-button {
            background-color: red;
            color: white;
        }
    </style>
</head>
<body>
    <a href="home.jsp">Torna alla Home</a>
    <div class="community-header">
        <h1 class="community-name"><%= communityBean != null ? communityBean.getNome() : "Community" %></h1>
        <p class="community-description"><%= communityBean != null ? communityBean.getDescrizione() : "Descrizione non disponibile" %></p>
    </div>
    <h2>Post della Community</h2>

    <% if (posts != null && !posts.isEmpty()) { %>
        <% for (PostBean post : posts) { %>
            <div class="post-container">
                <img src="<%= post.getImmagine() %>" alt="Post Image" class="post-image" />
                <h3 class="post-title"><%= post.getTitolo() %></h3>
                <p class="post-body"><%= post.getCorpo() %></p>
                <div class="post-info">
                    <p>Likes: <%= post.getLikes() %></p>
                    <p>Segnalazioni: <%= post.getSegnalazioni() %></p>
                    <p>Creato da: <%= post.getUtenteEmail() %></p>
                </div>
                <div class="interaction-buttons">
                    <form action="posts" method="get" style="display: inline;">
                        <input type="hidden" name="mode" value="like" />
                        <input type="hidden" name="postId" value="<%= post.getId() %>" />
                        <button type="submit" class="like-button">Like</button>
                    </form>
                    <form action="posts" method="get" style="display: inline;">
                        <input type="hidden" name="mode" value="segnala" />
                        <input type="hidden" name="postId" value="<%= post.getId() %>" />
                        <button type="submit" class="report-button">Segnala</button>
                    </form>
                    
                </div>
            </div>
        <% } %>
    <% } else { %>
        <p>Non ci sono post disponibili in questa community.</p>
    <% } %>

</body>
</html>
