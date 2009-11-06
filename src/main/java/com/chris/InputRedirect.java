package com.chris;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Redirect {@link InputStream} to a {@link org.slf4j.Logger}
 */
public class InputRedirect extends Thread
{

    /**
     * Level of logging to use with {@link org.slf4j.Logger}
     * 
     * @author cjmcmill
     */
    public enum Level
    {
	/**
	 * Direct input to the {@link Logger#info(String, Object, Object)} level
	 * of effective logging
	 */
	STANDARD,
	/**
	 * Direct input to the {@link Logger#trace(String, Object, Object)}
	 * level of effective logging. This level is not reccommended, use
	 * {@code Level.DEBUG} instead.
	 */
	TRACE,
	/**
	 * Direct input to the {@link Logger#debug(String, Object, Object)}
	 * level of effective logging
	 */
	DEBUG,
	/**
	 * Direct input to the {@link Logger#info(String, Object, Object)} level
	 * of effective logging
	 */
	INFO,
	/**
	 * Direct input to the {@link Logger#warn(String, Object, Object)} level
	 * of effective logging
	 */
	WARN,
	/**
	 * Direct input to the {@link Logger#error(String, Object, Object)}
	 * level of effective logging
	 */
	ERROR
    }

    private static Logger logger = LoggerFactory.getLogger(InputRedirect.class);

    private InputStream is;
    private Logger redirect;
    private Clock timeTeller;
    private Level logLevel;

    InputRedirect(InputStream is, Logger redirect, Level logLevel)
    {
	this.is = is;
	this.redirect = redirect;
	this.logLevel = logLevel;
	this.timeTeller = Clock.getInstance();
    }

    public void run()
    {
	try
	{
	    InputStreamReader isr = new InputStreamReader(is);
	    BufferedReader br = new BufferedReader(isr);
	    String line = null;
	    switch (logLevel)
	    {
		case TRACE:
		    while ((line = br.readLine()) != null)
		    {
			redirect.trace("{} {}", timeTeller.getTime(), line);
		    }
		    break;
		case DEBUG:
		    while ((line = br.readLine()) != null)
		    {
			redirect.debug("{} {}", timeTeller.getTime(), line);
		    }
		    break;
		case INFO:
		case STANDARD:
		    while ((line = br.readLine()) != null)
		    {
			redirect.info("{} {}", timeTeller.getTime(), line);
		    }
		    break;
		case WARN:
		    while ((line = br.readLine()) != null)
		    {
			redirect.warn("{} {}", timeTeller.getTime(), line);
		    }
		    break;
		case ERROR:
		    while ((line = br.readLine()) != null)
		    {
			redirect.error("{} {}", timeTeller.getTime(), line);
		    }
		    break;
		default:
		    break;
	    }
	}
	catch (IOException e)
	{
	    logger.error("IOException ", e);
	}
	catch (IllegalArgumentException e)
	{
	    logger.error("IllegalArgumentException ", e);
	}
    }
}
