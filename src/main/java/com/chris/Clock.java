package com.chris;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationFactory;

/**
 * Singleton to provide the current datetime formatted using either the default
 * format {@code [dd-MM-yyyy HH:mm:ss]} or the date format specified in {@code
 * dateFormat} from the {@code dateFormat} property in the configuration file .
 */
public class Clock
{
    private DateFormat dateFormat;
    private DateFormat defaultDateFormat = new SimpleDateFormat("[dd-MM-yyyy HH:mm:ss]");

    /**
     * Single static instance of the service class
     */
    private static Clock instance = new Clock();

    /**
     * Get the single instance of the Clock Class
     * 
     * @return Clock instance
     */
    public static Clock getInstance()
    {
	return instance;
    }

    private Clock()
    {
	try
	{
	    ConfigurationFactory factory = new ConfigurationFactory("/config.xml");
	    Configuration config = factory.getConfiguration();
	    dateFormat = new SimpleDateFormat(config.getString("dateFormat"));
	}
	catch (Exception e)
	{
	}

	if (dateFormat == null)
	    dateFormat = defaultDateFormat;
    }

    /**
     * Get the current time formatted according to the properties file
     * 
     * @return Current date time string
     */
    public String getTime()
    {
	return dateFormat.format(new Date());
    }

}
