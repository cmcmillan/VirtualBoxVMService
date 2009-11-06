package com.chris;

import java.io.File;
import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Command process with its output redirected to {@link org.slf4j.Logger}
 */
public class Command extends Thread
{
    private static Logger logger = LoggerFactory.getLogger(Command.class);

    private Clock clock;
    private String command;
    private String dir;
    private String identifier;
    private Runtime runtime;

    /**
     * Create a new Command that redirects input to the Logger class
     * 
     * @param identifier
     *            Name of the command process for identification in the
     *            processing log
     * @param runtime
     *            Runtime enviroment in which to start the process
     * @param command
     *            Command to be started as a new process
     * @param dir
     *            Working directory of the command process
     */
    public Command(String identifier, Runtime runtime, String command, String dir)
    {
	this.identifier = identifier;
	this.runtime = runtime;
	this.command = command;
	this.dir = dir;
	this.clock = Clock.getInstance();
    }

    public void run()
    {
	try
	{
	    logger.debug("{} Starting {}: {}",
		new Object[] { clock.getTime(), identifier, command });

	    // Working directory of the process
	    File directory = new File(dir);
	    // Start the process in a new thread
	    Process process = runtime.exec(command, null, directory);

	    // Redirect the standard input stream to logger.info
	    InputRedirect out =
		    new InputRedirect(process.getInputStream(), logger, InputRedirect.Level.INFO);

	    // Redirect the standard err stream to logger.error
	    InputRedirect err =
		    new InputRedirect(process.getErrorStream(), logger, InputRedirect.Level.ERROR);

	    // Start to read the input streams
	    out.start();
	    err.start();

	    // Wait for the process to exit
	    int exitVal = process.waitFor();

	    if (exitVal == 0)
		logger.debug("{} {} succeeded", clock.getTime(), identifier);
	    else
		logger.error("{} {} exit value: {}", new Object[] { clock.getTime(), identifier,
			exitVal });

	    out.join();
	    err.join();

	}
	catch (IOException e)
	{
	    logger.error("IOException ", e);
	}
	catch (InterruptedException e)
	{
	    logger.error("InterruptedException ", e);
	}
	catch (SecurityException e)
	{
	    logger.error("NoSuchMethodException ", e);
	}
    }
}
