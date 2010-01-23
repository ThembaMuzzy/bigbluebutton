<!--

BigBlueButton - http://www.bigbluebutton.org

Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.

BigBlueButton is free software; you can redistribute it and/or modify it under the 
terms of the GNU Lesser General Public License as published by the Free Software 
Foundation; either version 3 of the License, or (at your option) any later 
version. 

BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along 
with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.

Author: Fred Dixon <ffdixon@bigbluebutton.org>

-->

<%@ page
	import="java.util.*,java.io.*,java.net.*,javax.crypto.*,javax.xml.parsers.*,org.w3c.dom.Document,org.xml.sax.*"
	errorPage="error.jsp" %>

<%@ page import="org.apache.commons.codec.digest.*"%>
<%@ include file="bbb_api_conf.jsp"%>

<%!

// 
// Create a meeting and return a URL to join it
//
public String getJoinURL(String username, String meetingID, String welcome) {
		String base_url_create = BigBlueButtonURL + "api/create?";
		String base_url_join = BigBlueButtonURL + "api/join?";
		
		String welcome_param = "";
		String checksum = "";
		
		Random random = new Random();
		Integer voiceBridge = 70000 + random.nextInt(9999);
		
		if ( (welcome != null) && ! welcome.equals("")) {
			welcome_param = "&welcome=" + urlEncode(welcome);
		}
			
		String create_parameters = "name=" + urlEncode(username) + "&meetingID=" + urlEncode(meetingID)
		+ welcome_param + "&attendeePW=ap&moderatorPW=mp&voiceBridge="+voiceBridge;

		Document doc = null;

		try {
			// Attempt to create a meeting of that name
			String xml = getURL(base_url_create + create_parameters + "&checksum=" + checksum(create_parameters + salt) );
			doc = parseXml(xml);		
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (doc.getElementsByTagName("returncode").item(0).getTextContent()
				.trim().equals("SUCCESS")) {

			String meetingToken = "";

			if (doc.getElementsByTagName("meetingToken").item(0) != null) {
				meetingToken = doc.getElementsByTagName("meetingToken").item(0)
						.getTextContent().trim();
			}

			String join_parameters = "meetingToken=" + meetingToken + "&fullName=" + urlEncode(username)
					+ "&password=mp";

			return base_url_join + join_parameters + "&checksum=" + checksum(join_parameters + salt);

		}
		return doc.getElementsByTagName("messageKey").item(0).getTextContent().trim() 
		+ ": " + doc.getElementsByTagName("message").item(0).getTextContent().trim();
	}

	public static String checksum(String s) {
		String checksum = "";
		try {
			checksum = org.apache.commons.codec.digest.DigestUtils.shaHex(s);
			// checksum = DigestUtils.shaHex(s);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return checksum;
	}

	public static String getURL(String url) {
		StringBuffer response = null;

		// Verify that the communication will be over SSL.
		if (!url.startsWith("http")) {
			// throw new MalformedURLException("getURL(): URL \"" + url +
			// "\" does not use HTTPS.");
		}

		try {
			URL u = new URL(url);
			HttpURLConnection httpConnection = (HttpURLConnection) u
					.openConnection();

			httpConnection.setUseCaches(false);
			httpConnection.setDoOutput(true);
			httpConnection.setRequestMethod("GET");

			httpConnection.connect();
			int responseCode = httpConnection.getResponseCode();
			if (responseCode == HttpURLConnection.HTTP_OK) {
				InputStream input = httpConnection.getInputStream();

				// Read server's response.
				response = new StringBuffer();
				Reader reader = new InputStreamReader(input, "UTF-8");
				reader = new BufferedReader(reader);
				char[] buffer = new char[1024];
				for (int n = 0; n >= 0;) {
					n = reader.read(buffer, 0, buffer.length);
					if (n > 0)
						response.append(buffer, 0, n);
				}

				input.close();
				httpConnection.disconnect();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (response != null) {
			return response.toString();
		} else {
			return "";
		}
	}
	
	public String getURLisMeetingRunning(String meetingToken, String meetingID) {
		String base_main = "meetingToken=" + meetingToken + "&meetingID=" + urlEncode(meetingID);
		String base_url = BigBlueButtonURL + "api/isMeetingRunning?";
		String checksum ="";
		
		try {
			checksum = DigestUtils.shaHex(base_main + salt);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return base_url + base_main + "&checksum=" + checksum;
	}

		
	public String isMeetingRunning(String meetingToken, String meetingID) {
		String base_main = "meetingToken=" + meetingToken + "&meetingID=" + urlEncode(meetingID);
		String base_url = BigBlueButtonURL + "api/isMeetingRunning?";
		String checksum ="";
		
		try {
			checksum = DigestUtils.shaHex(base_main + salt);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		String xml = getURL(base_url + base_main + "&checksum=" + checksum);

		Document doc = null;
		try {
			doc = parseXml(xml);
		} catch (Exception e) {
			e.printStackTrace();
		}

		if (doc.getElementsByTagName("returncode").item(0).getTextContent()
				.trim().equals("SUCCESS")) {
			return doc.getElementsByTagName("running").item(0).getTextContent().trim();
		}
		
		return  "false";
		
	}
	
	
	public static Document parseXml(String xml)
			throws ParserConfigurationException, IOException, SAXException {
		DocumentBuilderFactory docFactory = DocumentBuilderFactory
				.newInstance();
		DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
		Document doc = docBuilder.parse(new InputSource(new StringReader(xml)));
		return doc;
	}
	
	
	public static String urlEncode(String s) {	
		try {
			return URLEncoder.encode(s, "UTF-8");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
%>
