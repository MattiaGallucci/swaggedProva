<%@page import="model.PostDAO"%>
<%@page import="model.PostBean"%>
<%@page import="model.SalvaPostBean"%>
<%@page import="model.ApprezzaPostBean"%>
<%@page import="model.CommentoBean"%>
<%@page import="model.UtenteBean"%>
<%@page import="java.util.List"%>
<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    Boolean isLogged = (Boolean) session.getAttribute("logged");
    if (isLogged == null || !isLogged) {
        response.sendRedirect("login.jsp");
        return;
    }

    UtenteBean utente = (UtenteBean) request.getAttribute("utente");
    List<PostBean> postCreati = (List<PostBean>) request.getAttribute("postCreati");
    List<SalvaPostBean> postSalvati = (List<SalvaPostBean>) request.getAttribute("postSalvati");
    List<ApprezzaPostBean> postApprezzati = (List<ApprezzaPostBean>) request.getAttribute("postApprezzati");
    List<CommentoBean> commentiCreati = (List<CommentoBean>) request.getAttribute("commentiCreati");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Profilo di <%= utente.getUsername() %></title>
<style>
    body {
        font-family: Arial, sans-serif;
    }

    .section {
        margin-top: 20px;
    }

    .post-container {
        border: 1px solid #ddd;
        padding: 20px;
        margin: 10px 0;
        box-shadow: 2px 2px 8px rgba(0, 0, 0, 0.1);
    }

    .post-title {
        font-size: 20px;
        font-weight: bold;
    }

    .post-body {
        margin-top: 10px;
    }

    .post-info {
        font-size: 14px;
        color: #555;
    }

    /* Styling for post image */
    .post-image {
        margin-top: 15px; /* Space above the image */
        text-align: center; /* Centers the image */
    }

    .post-image img {
        max-width: 100%; /* Ensures the image does not overflow the container */
        height: auto; /* Maintains aspect ratio */
        border-radius: 8px; /* Optional: round the corners of the image */
    }
</style>


</head>
<body>
<!-- Cerchio per l'immagine del profilo -->
<div class="profile-image-container">
    <img src="<%=request.getContextPath() + "/images/pfp/" + utente.getImmagine()%>" alt="Immagine Profilo" class="profile-image">
    <form action="account" method="post" enctype="multipart/form-data">
    	<input type="hidden" name="mode" value="modificaImmagine"/>
    	<label for="immagine">URL Immagine:</label>
		<input type="file" id="immagine" name="immagine" placeholder="Immagine" accept="image/*"/>
		<button type="submit">Aggiorna Foto Profilo</button>    
    </form>
</div>
    <h1>Profilo di <%= utente.getUsername() %></h1>
    <p>Email: <%= utente.getEmail() %></p>
    <p>Stato: <%= utente.isBandito() ? "Bandito" : "Attivo" %></p>

    <div class="section">
    <h2>Post Creati</h2>
    <% if (postCreati != null && !postCreati.isEmpty()) { %>
        <% for (PostBean post : postCreati) { %>
            <div class="post-container">
                <div class="post-title"><%= post.getTitolo() %></div>
                <div class="post-body"><%= post.getCorpo() %></div>
                <div class="post-info">
                    <p>Likes: <%= post.getLikes() %></p>
                    <p>Segnalazioni: <%= post.getSegnalazioni() %></p>
                </div>
                
                <% if (post.getImmagine() != null && !post.getImmagine().isEmpty()) { %>
                    <div class="post-image">
                        <img src="<%=request.getContextPath() + "/images/post/" + post.getImmagine()%>" alt="Immagine del post" />
                    </div>
                <% } %>
            </div>
        <% } %>
    <% } else { %>
        <p>Nessun post creato.</p>
    <% } %>
</div>


    <div class="section">
        <h2>Post Salvati</h2>
        <% if (postSalvati != null && !postSalvati.isEmpty()) { %>
            <% for (SalvaPostBean salvaPost : postSalvati) { 
            	PostDAO postDAO = new PostDAO();
            	PostBean post = postDAO.doRetrieveById(salvaPost.getPostId());%>
                <div class="post-container">
                    <div class="post-title"><%= post.getTitolo() %></div>
                    <p>Salvato in data: <%= post.getLikes() %></p>
                </div>
            <% } %>
        <% } else { %>
            <p>Nessun post salvato.</p>
        <% } %>
    </div>

    <div class="section">
        <h2>Post Apprezzati</h2>
        <% if (postApprezzati != null && !postApprezzati.isEmpty()) { %>
            <% for (ApprezzaPostBean apprezzaPost : postApprezzati) { 
            	PostDAO postDAO = new PostDAO();
            	PostBean post = postDAO.doRetrieveById(apprezzaPost.getPostId());%>
                <div class="post-container">
                    <div class="post-title"><%= post.getTitolo()%></div>
                    <p>Apprezzato in data: <%= post.getLikes()%></p>
                </div>
            <% } %>
        <% } else { %>
            <p>Nessun post apprezzato.</p>
        <% } %>
    </div>

    <div class="section">
        <h2>Commenti Creati</h2>
        <% if (commentiCreati != null && !commentiCreati.isEmpty()) { %>
            <% for (CommentoBean commento : commentiCreati) { %>
                <div class="post-container">
                    <p><%= commento.getCorpo() %></p>
                    <div class="post-info">
                        <p>Likes: <%= commento.getLikes() %></p>
                        <p>Segnalazioni: <%= commento.getSegnalazioni() %></p>
                    </div>
                </div>
            <% } %>
        <% } else { %>
            <p>Nessun commento creato.</p>
        <% } %>
    </div>
    
    <div class="section">
    <h2>Modifica Credenziali</h2>
    <form action="account" method="get">
    <input type="hidden" name="mode" value="modifica">
        <div>
            <label for="username">Username:</label>
            <input type="text" id="usernameNuovo" name="usernameNuovo" value="<%= utente.getUsername() %>" placeholder="Username attuale" required>
        </div>
        <div>
            <label for="email">Email:</label>
            <input type="email" id="emailNuova" name="emailNuova" value="<%= utente.getEmail() %>" placeholder="Email attuale" required>
        </div>
        <div>
            <label for="password">Password:</label>
            <input type="password" id="passwordNuova" name="passwordNuova" placeholder="Nuova password (lascia vuoto per mantenere attuale)">
        </div>
        <div>
            <label for="passwordCheck">Conferma Password:</label>
            <input type="password" id="passwordNuovaCheck" name="passwordNuovaCheck" placeholder="Ripeti password">
        </div>
        <input type="submit" value="Aggiorna Credenziali">
    </form>
</div>
    

    <a href="LogoutServlet">Logout</a>
</body>
</html>
