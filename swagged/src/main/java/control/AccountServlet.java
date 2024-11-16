package control;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.Base64;
import java.util.Iterator;
import java.util.Base64.Encoder;
import java.util.List;
import java.util.UUID;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import model.ApprezzaPostBean;
import model.ApprezzaPostDAO;
import model.CommentoBean;
import model.CommentoDAO;
import model.PostBean;
import model.PostDAO;
import model.SalvaPostBean;
import model.SalvaPostDAO;
import model.UtenteBean;
import model.UtenteDAO;

/**
 * Servlet implementation class AccountServlet
 */
@WebServlet("/account")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class AccountServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private static final String UPLOAD_DIR = "images/pfp";
	
	private boolean isImageFile(Part filePart) {
		String contentType = filePart.getContentType();
		return contentType != null && (contentType.equals("image/jpeg") || contentType.equals("image/png") || contentType.equals("image/gif") || contentType.equals("image/jpg"));
	}
	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String mode = request.getParameter("mode");
        UtenteDAO utenteDAO = new UtenteDAO();
        String path = null;
        
        try {
        	if("modificaImmagine".equals(mode)) {
        		UtenteBean utenteBean = new UtenteBean();
        		String email = (String) request.getSession().getAttribute("email");

        		Part filePart = request.getPart("immagine");
                if (filePart == null || !isImageFile(filePart)) {
        			request.setAttribute("errorMessage", "Per favore carica un file immagine valido (jpg, jpeg, png, gif).");
        			request.getRequestDispatcher("/home.jsp").forward(request, response);
        			return;
        		}
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        		String applicationPath = getServletContext().getRealPath("");
        		String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
        		File uploadDir = new File(uploadFilePath);
        		if (!uploadDir.exists()) {
        			uploadDir.mkdirs();
        		}
        		String sanitizedFileName = fileName.replaceAll("\\s+", "_");
        		String filePath = uploadFilePath + File.separator + sanitizedFileName;
        		File file = new File(filePath);
        		while (file.exists()) {
        			String uniqueID = UUID.randomUUID().toString();
        			sanitizedFileName = uniqueID + "_" + sanitizedFileName;
        			filePath = uploadFilePath + File.separator + sanitizedFileName;
        			file = new File(filePath);
        		}
        		try {
        			Files.copy(filePart.getInputStream(), Paths.get(filePath));
        		} catch (IOException e) {
        			request.setAttribute("errorMessage", "Errore durante il caricamento dell'immagine.");
        			request.getRequestDispatcher("/home.jsp").forward(request, response);
        			return;
        		}
        		String relativeFileName = sanitizedFileName;
        		
        		utenteBean.setImmagine(relativeFileName);
        		
        		utenteDAO.doUpdate(utenteBean, email);
                path = "posts?mode=home";
        	}
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore nel recupero dei dati.");
            path = "error.jsp"; // Pagina di errore
        }
        
        RequestDispatcher view = request.getRequestDispatcher(path);
        view.forward(request, response);
	}
    
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String mode = request.getParameter("mode");
        UtenteDAO utenteDAO = new UtenteDAO();
        String path = null;
        boolean flag = false;
        
        try {
        	if("profilo".equalsIgnoreCase(mode)) {
        		String utenteEmail = (String) request.getSession().getAttribute("email");
        		UtenteBean utenteBean = utenteDAO.doRetrieveByEmail(utenteEmail);
        		request.setAttribute("utente", utenteBean);
        		
        		CommentoDAO commentoDAO = new CommentoDAO();
        		List<CommentoBean> commentiCreati = commentoDAO.doRetrieveByUtenteEmail(utenteEmail);
        		request.setAttribute("commentiCreati", commentiCreati);
        		
        		PostDAO postDAO = new PostDAO();
        		List<PostBean> postCreati = postDAO.doRetrieveByEmail(utenteEmail);
        		request.setAttribute("postCreati", postCreati);
        		
        		SalvaPostDAO salvaPostDAO = new SalvaPostDAO();
        		List<SalvaPostBean> postSalvati = salvaPostDAO.doRetrieveByEmail(utenteEmail);
        		request.setAttribute("postSalvati", postSalvati);
        		
        		ApprezzaPostDAO apprezzaPostDAO = new ApprezzaPostDAO();
        		List<ApprezzaPostBean> postApprezzati = apprezzaPostDAO.doRetrieveByEmail(utenteEmail);
        		request.setAttribute("postApprezzati", postApprezzati);
        		
        		path="profilo.jsp";
        	} else if ("modifica".equalsIgnoreCase(mode)) {
                UtenteBean utenteBean = new UtenteBean();
                String email = (String) request.getSession().getAttribute("email");
                String username = (String) request.getSession().getAttribute("username");
                String password = (String) request.getSession().getAttribute("password");
                Encoder encoder = Base64.getEncoder();

                String usernameNuovo = request.getParameter("usernameNuovo");
                String emailNuova = request.getParameter("emailNuova");
                String passwordNuova = request.getParameter("passwordNuova");
                String passwordNuovaCheck = request.getParameter("passwordNuovaCheck");
                String pwd64 = null;

                try {
                    utenteBean = utenteDAO.doRetrieveByEmail(email);
                    List<UtenteBean> utenti = utenteDAO.doRetrieveAll("");
                    Iterator<UtenteBean> iterator = utenti.iterator();
                    UtenteBean utenteDB = new UtenteBean();

                    // Controllo se il nuovo username esiste già
                    if (!utenteBean.getUsername().equals(usernameNuovo)) {
                        while (iterator.hasNext()) {
                            utenteDB = iterator.next();
                            if (utenteDB.getUsername().equals(usernameNuovo)) {
                                flag = true;
                                break;
                            }
                        }
                    }

                    // Resetta l'iteratore per controllare l'email
                    iterator = utenti.iterator();
                    if (!utenteBean.getEmail().equals(emailNuova)) {
                        while (iterator.hasNext()) {
                            utenteDB = iterator.next();
                            if (utenteDB.getEmail().equals(emailNuova)) {
                                flag = true;
                                break;
                            }
                        }
                    }

                    // Controllo password
                    if (passwordNuova != null && !passwordNuova.isEmpty() && 
                        passwordNuovaCheck != null && !passwordNuovaCheck.isEmpty() &&
                        passwordNuova.equals(passwordNuovaCheck)) {
                        pwd64 = encoder.encodeToString(passwordNuova.getBytes());
                    } else {
                        pwd64 = utenteBean.getPassword();
                    }

                    // Aggiornamento utente se non ci sono conflitti
                    if (!flag) {
                        utenteBean.setUsername(usernameNuovo);
                        utenteBean.setEmail(emailNuova);
                        utenteBean.setPassword(pwd64);
                        utenteDAO.doUpdate(utenteBean, email);
                        path = "account?mode=profilo";
                    } else {
                        request.setAttribute("errorMessage", "Username o email già in uso.");
                        path = "account?mode=profilo"; // Riporta a profilo con messaggio di errore
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    request.setAttribute("errorMessage", "Errore nel recupero dei dati.");
                    path = "error.jsp"; // Pagina di errore
                }
                if(path.equals(null))
            		path = "posts?mode=home";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Errore nel recupero dei dati.");
            path = "error.jsp"; // Pagina di errore
        }

        // Inoltra la richiesta alla pagina appropriata
        RequestDispatcher view = request.getRequestDispatcher(path);
        view.forward(request, response);
	}
}
