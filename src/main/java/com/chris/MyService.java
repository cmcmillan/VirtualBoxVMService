package com.chris;

import java.lang.Thread.State;
import java.security.InvalidParameterException;
import java.text.MessageFormat;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.ConfigurationFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Simple service class that writes a message to standard out every minute.
 */
public class MyService
{
    private static Logger logger = LoggerFactory.getLogger(MyService.class);
    /**
     * Single static instance of the service class
     */
    private static MyService serviceInstance = new MyService();

    private static final String configFileName = "/config.xml";
    
    private String runnerIdentifier;
    private String shutdownIdentifier;

    private String serviceName;
    private Configuration config;
    private Runtime runtime;
    private Clock clock;

    /**
     * Static method called by prunsrv to start/stop the service. Pass the
     * argument "start" to start the service, and pass "stop" to stop the
     * service.
     * 
     * @param args
     *            Arguement used to start or stop the service
     * 
     * @throws ConfigurationException
     *             Unable to load properties file
     */
    public static void main(String args[]) throws ConfigurationException
    {
	String cmd = "";
	if (args.length > 0)
	{
	    cmd = args[0];
	    serviceInstance.initVars();
	    serviceInstance.assertVars();
	}

	if ("start".equals(cmd))
	{
	    serviceInstance.start();
	}
	else if ("stop".equals(cmd))
	{
	    serviceInstance.stop();
	}
	else
	{
	    logger.error("'{}' is an invalid argument. Use {} or {}", new Object[] { cmd,
		    "'start' to start the service", "'stop' to stop the service" });
	    throw new InvalidParameterException(MessageFormat.format("Invalid argument: '{0}'", cmd));
	}
    }
    
    private void assertVars()
    {
	if (runtime == null)
	    throw new NullPointerException("Program error: Runtime is null");

	String[] mustExistedKeys =
		new String[] { "startupCommand", "shutdownCommand", "workingDir" };

	for (String eachKey : mustExistedKeys)
	{
	    if (!config.containsKey(eachKey))
		throw new NullPointerException("Key '" + eachKey + "' must exists in: "
			+ configFileName);
	}
    }

    private void initVars() throws ConfigurationException
    {
	clock = Clock.getInstance();
	runtime = Runtime.getRuntime();

	ConfigurationFactory factory = new ConfigurationFactory(configFileName);
	config = factory.getConfiguration();

	serviceName = config.getString("SERVICE_NAME");
	runnerIdentifier = serviceName + "_Runner";
	shutdownIdentifier = serviceName + "_Stopper";
    }

    /**
     * Start this service instance
     */
    private void start()
    {
	logger.debug("{} Service started", clock.getTime());

	Command runnerCommand =
		new Command(runnerIdentifier, runtime, config.getString("startupCommand"), config
			.getString("workingDir"));
	runnerCommand.start();

	while (runnerCommand.getState() != State.TERMINATED)
	{
	    try
	    {
		logger.debug("{} Joining with runner command", clock.getTime());
		runnerCommand.join();
	    }
	    catch (Exception e)
	    {
		logger.error("Error starting service", e);
	    }
	}
	logger.debug("{} Service stopped", clock.getTime());
    }

    /**
     * Stop this service instance
     */
    private void stop()
    {
	logger.debug("{} Executing shutdown command", clock.getTime());

	Command shutdownCommand =
		new Command(shutdownIdentifier, runtime, config.getString("shutdownCommand"),
			config.getString("workingDir"));
	shutdownCommand.start();

	while (shutdownCommand.getState() != State.TERMINATED)
	{
	    try
	    {
		logger.debug("{} Shutdown thread join with shutdown command", clock.getTime());
		shutdownCommand.join();
	    }
	    catch (Exception e)
	    {
		logger.error("Error during shutdown", e);
	    }
	}
	logger.debug("{} Shutdown command executed", clock.getTime());
    }
}
