#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import division
from __future__ import print_function
from psychopy import visual, event, core, logging, gui
from psychopy.event import getKeys, waitKeys
import os
import random
import glob
import json
import sys
import csv
import pylink
import psychopy.gui
import psychopy.core
import math, numpy, serial
import pandas as pd
from psychopy import data
from psychopy import logging

#############################
## Presentation parameters ##
#############################
mainClock = core.Clock()
stimulationClock = core.Clock()

nbSpider = 45  # Number of pictures per run
nbNeutral = 15
nbCatch = 6 # Number of catch per run
Tpic = 4   # Stimulus duration
MinJitter = 2
MaxJitter = 3
nbRun = 5
thisDir = 'PATH://2021 - spider20 EXP/run'
# initialize clock
maindata = []

# Store info about the experiment session
expName = 'spider20'  # from the Builder filename that created this script
expInfo = {u'session': u'0', u'participant': u'p01'}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False:
    core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName
i_session = int(expInfo['session'])

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = thisDir +'/../onsets/' + u'/%s_%s_%s' % (expInfo['participant'], 'run_' + expInfo['session'], expName) 
csvname  = thisDir +'/../onsets/' + u'/%s_%s_%s' % (expInfo['participant'], 'run_' + expInfo['session'], expName)  + '.csv'

# save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.INFO)

######################
## Randomize images ##
######################
if i_session == 1:
    print("merde")
    # get spider pictures
    spiderList = glob.glob(thisDir + "/../stimuli/spider/Sp*.jpg")
    random.shuffle(spiderList) # randomize spider list
    
    # get neutral pictures
    neutralList = glob.glob(thisDir + "/../stimuli/neutral/Ne*.jpg")
    random.shuffle(neutralList) # randomize neutral pictures
    
    # get catch pictures
    catchList = glob.glob(thisDir + "/../stimuli/catch/*.png")
    random.shuffle(catchList) # randomize catch trials
    
    # Create sequences of pictures to be displayed for each run
    imageIDPath = [[] for i in range(nbRun)] # initialize variable
    txtRun      = [[] for i in range(nbRun)] # initialize variable
    imageRun    = [[] for i in range(nbRun)] # initialize variable
    for iRun in range(0,nbRun):
        # Assign pictures and catch trials to each run
        imageRun[iRun]    =  catchList + spiderList[iRun * nbSpider : (iRun + 1) * nbSpider] + neutralList[iRun * nbNeutral: (iRun + 1) * nbNeutral]
        random.shuffle(imageRun[iRun])
        # Save pictures of each run in a txt file
        imageIDPath[iRun] = thisDir + '/../txtRun/'+ u'/%s_%s_%s' % (expInfo['participant'], 'imagerun_' + str(iRun + 1), expName) + '.txt' # output path of txt
        if os.path.isfile(imageIDPath[iRun]) == False:
            f = open(imageIDPath[iRun], 'w')
            f.write("\n".join(map(str, imageRun[iRun])))
    print('Pictures saved in ' + imageIDPath[0])    

    # SANITY CHECKS
    # check total number of pictures
    print("Number of spider pictures : " + str(len(spiderList)) + "\n" +
          "Number of neutral pictures : " + str(len(neutralList)) + "\n" +
          "Number of catch trials : " + str(len(catchList)))
    # check if number of catch trials in folder matches the number entered in the list of parameters
    if len(catchList) != nbCatch:
        print('Warning: Please check number of catch pictures in the catch folder')
    # check if number of stimuli per run
    if all(len(x) == len(imageRun[0]) for x in imageRun):
        print(str(len(imageRun[0])) + " stimuli (catch + neutral + spider) per run")
    else: 
        print('Warning : Number of stimuli per run not balanced')


# Save data in csv file
csvfile = open(csvname, 'w')
writer = csv.writer(csvfile, delimiter = ";")  
writer.writerow(['event', 'trial', 'picture ID', 'onset', 'jitter', 'catch', 'reaction time', 'time from script start'])
    
###############################
## CREATE OBJECTS TO DISPLAY ##
###############################

# Create window
win = visual.Window(fullscr=True, size=[1000, 750], color=(0,0,0), colorSpace='rgb', units='pix', monitor='testMonitor', screen=1)
# Initialize objects of instruction 1
instr1 = visual.TextStim(win, text="""Das Experiment wird in Kürze beginnen.""", pos = (0, -60), height = 40, wrapWidth=1000)
# Initialize objects of instruction 2
instr2 = visual.TextStim(win, text="""Versuchen Sie, sich nicht zu bewegen, bleiben Sie ruhig liegen und konzentrieren Sie sich auf die nun folgenden Bilder.""",  pos=(0, 60), height=40, wrapWidth=1000) 
# Initialize objects of pause
pause = visual.TextStim(win, text="""Pause""", height=40, pos=(0, 0), wrapWidth=1000)
# Initialize objects of fication cross
fixdot = visual.ImageStim(win, image = thisDir+'/../stimuli/dot/FixDot.png', pos=(0, 0))
# Initialize Thank you slide
thankyou = visual.TextStim(win=win, text = """Vielen Dank für Ihre Teilnahme an dieser Studie!""", pos=[0, 0], height=40, wrapWidth=1500)
thankyou2 = visual.TextStim(win=win, text = """Bitte einstweilen ruhig liegen bleiben. """, pos=[0, -120], height=40, wrapWidth=1500)
counter = 1

# open txt file to read trials 
imageIDread = thisDir + '/../txtRun/'+ u'/%s_%s_%s' % (expInfo['participant'], 'imagerun_' + expInfo['session'], expName) + '.txt' # output path of txt
with open(imageIDread) as f:
   txtRun = f.read().splitlines() 
print('Presenting images from ' + imageIDread)

######################
## Blocks of events ##
######################

def display_run(list):
    counter = 1        
    for image in list:
        jitter = round(random.uniform(MinJitter, MaxJitter),1)        # display fixation cross 
        event.clearEvents()
        fixdot.draw()
        win.flip()
        core.wait(jitter)
        myItem = visual.ImageStim(win=win, image=image, size=[800,600], units='pix', pos=[0, 0])        # display picture 
        print(image)
        myItem.draw()
        win.flip()
        onset = stimulationClock.getTime()
        timestamp = mainClock.getTime()
        if 'catch' in image:
            key = waitKeys(keyList = ['1', '2', '3', '4'])       # wait for scanner trigger (or press'6') 
            rt = stimulationClock.getTime()- onset # catch reaction time
            maindata.append([counter, os.path.basename(image), onset, jitter, int(key[0]), rt, timestamp])
        else:
            core.wait(Tpic)
            maindata.append([counter, os.path.basename(image), onset, jitter, 0, '', timestamp])
        counter = counter + 1 
    # save data :
    for row in range(len(maindata)):
        d = maindata[row]
        writer.writerow([row+1,d[0],d[1],d[2],d[3], d[4], d[5], d[6]])

def display_pause():
    event.clearEvents()
    pause.draw()
    win.flip()
    maindata.append(['Pause', 'Pause', stimulationClock.getTime(), 0, 99])
    print('...the experiment is paused, stop the scanner...')
    print('...talk to participant...')
    core.wait(8)

def display_instruction():
    instr2.draw()
    win.flip()
    print('...instructions are displayed...')
    core.wait(5)


def proceed(message):
    proceed_gui = psychopy.gui.Dlg()
    proceed = False 
    # Display experimenter instructions
    while proceed == False:
        proceed_gui.addText(message)
        proceed_gui.show()
        if proceed_gui.OK == False: # Quit program if user hits 'cancel'
            core.quit()
        else:  
            proceed = True


#################
## run routine ##
#################

proceed('Click to start run ' + str(i_session) + '\nDO NOT forget to click on the presentation screen')

print('...Run ' + str(i_session) +' launched... \nWaiting for scanner trigger... \n\nDO NOT forget to click on the presentation screen\n')
triggerkey = event.waitKeys(keyList = ['space', '6']) 
stimulationClock.reset()
timestamp = stimulationClock.getTime()
writer.writerow(['', 'keypress: 6', '', 'reset: t = 0', '', '', '', timestamp ])

display_instruction()
display_run(txtRun)

timestamp = mainClock.getTime()
writer.writerow(['', 'end of run', '', '', '', '', '', timestamp ])

display_pause()

csvfile.close()
logging.flush()
win.close()
core.quit()
