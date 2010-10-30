#!python -u
# -*- coding: utf-8 -*-
# From Qwt Widget Library
# Copyright (C) 1997   Josef Wilgen
# Copyright (C) 2002   Uwe Rathmann
# License: LGPL
import math

EPS = 1.e-6

def fuzzyCompare(value1, value2, intervalSize):
    '''
    Compare 2 values, relative to an interval
    '''
    eps = abs(EPS * intervalSize)
    
    if value2 - value1 > eps:
        return -1
    elif value1 - value2 > eps:
        return 1
    else:
        return 0
    
def ceilEps(value, intervalSize):
    '''
    Ceil a value, relative to an interval
    '''
    eps = EPS * intervalSize
    value = (value - eps) / intervalSize
    return math.ceil(value) * intervalSize

def floorEps(value, intervalSize ):
    '''
    Floor a value, relative to an interval
    '''
    eps = EPS * intervalSize
    value = (value + eps) / intervalSize
    return math.floor(value) * intervalSize

def divideEps(intervalSize, numSteps):
    '''
    Divide an interval into steps
    '''
    if numSteps == 0. or intervalSize == 0.:
        return 0.

    return (intervalSize - (EPS * intervalSize )) / numSteps

def ceil125(x):
    '''
    Find the smallest value out of {1,2,5}*10^n with an
    integer number n which is greater than or equal to x
    '''
    if x == 0.:
        return 0.
    
    sign = 1. if x > 0. else -1.
    lx = math.log10(abs(x))
    p10 = math.floor(lx)
    
    fr = math.pow(10.0, lx - p10)
    
    if fr <= 1.:
        fr = 1.
    elif fr <= 2.:
        fr = 2.
    elif fr <= 5.:
        fr = 5.
    else:
        fr = 10.
    
    return sign * fr * math.pow(10., p10)

def floor125(x):
    '''
    Find the largest value out of {1,2,5}*10^n with an 
    integer number n which is smaller than or equal to x
    '''
    if x == 0.:
        return 0.
    
    sign = 1. if x > 0. else -1.
    lx = math.log10(abs(x))
    p10 = math.floor(lx)
    
    fr = math.pow(10.0, lx - p10)
    
    if fr >= 10.:
        fr = 10.
    elif fr >= 5.:
        fr = 5.
    elif fr >= 2.:
        fr = 2.
    else:
        fr = 1.
    
    return sign * fr * math.pow(10., p10)

def align(x1, x2, stepSize):
    '''
    Align an interval to a step size
    '''
    x1 = floorEps(min(x1,x2), stepSize)
    if fuzzyCompare(min(x1,x2), x1, stepSize) == 0:
        x1 = min(x1,x2)
    
    x2 = ceilEps(max(x1,x2), stepSize)
    if fuzzyCompare(max(x1,x2), x2, stepSize) == 0:
        x2 = max(x1,x2)
    
    return x1,x2
    
class Scale:
    def __init__(self, lowerMargin = 0., upperMargin = 0.):
        self.lowerMargin = lowerMargin
        self.upperMargin = upperMargin
    
    def divideInterval(self, intervalSize, numSteps):
        '''
        Calculate a step size for an interval size
        '''
        if numSteps <= 0:
            return 0.
        
        v = divideEps(intervalSize, numSteps)
        return ceil125(v)
    
    def autoScale(self, x1, x2, maxNumSteps):
        '''
        Align and divide an interval
        '''
        width = abs(x2 - x1)
        x1 = min(x1,x2) - self.lowerMargin
        x2 = max(x1,x2) + self.upperMargin
        
        if width == 0.:
            v = min(x1,x2)
            delta = .5 if v == 0. else abs(.5*v)
            x1 = v - delta
            x2 = v + delta
        
        stepSize = self.divideInterval(width, max(maxNumSteps,1))
        
        return stepSize
    
    def divideScale(x1, x2, maxMajSteps, imaxMinSteps, stepSize):
        """
        Calculate ticks for an interval
        """
        width = x2 - x1
        if width <= 0.:
            return 0.,0.
        
        stepSize = abs(stepSize)
        if stepSize == 0.:
            if maxMajSteps < 1:
                maxMajSteps = 1
                
            stepSize = self.divideInterval(width, maxMajSteps )
        
        if stepSize != 0.:
            ticks = self.buildTicks(x1, x2, stepSize, maxMinSteps)
    
    def buildTicks(self, x1, x2, stepSize, maxMinSteps = 2):
        x1, x2 = align(x1, x2, stepSize)
        
        majorTicks = self.buildMajorTicks(x1, x2, stepSize)
        
        if maxMinSteps > 0:
            minorTicks = self.buildMinorTicks(majorTicks, maxMinSteps, stepSize)
        else:
            minorTicks = ()
        
        return majorTicks, minorTicks
        
    def buildMajorTicks(self, x1, x2, stepSize):
        """
        Calculate major ticks for an interval
        """
        numTicks = int(round(abs(x2 - x1) / stepSize))
        
        if numTicks > 10000:
            numTicks = 10000
        
        x = min(x1,x2)
        ticks = [x]
        for i in range(1, numTicks):
            ticks.append(x + i*stepSize)
        
        ticks.append(max(x1,x2))
        
        return ticks
    
    def buildMinorTicks(self, majorTicks, maxMinSteps, stepSize):
        """
        Calculate minor/medium ticks for major ticks
        """
        minStep = self.divideInterval(stepSize, maxMinSteps)
        if minStep == 0.:
            return
        
        # ticks per interval
        numTicks = int(math.ceil(abs(stepSize / minStep)) - 1)
        
        # Do the minor steps fit into the interval?
        if fuzzyCompare((numTicks+1)*abs(minStep), abs(stepSize), stepSize ) > 0:
            numTicks = 1
            minStep = stepSize * .5
        
        # calculate minor ticks
        minorTicks = []
        for i in range(len(majorTicks) - 1):
            val = majorTicks[i]
            
            for k in range(numTicks):
                val += minStep
                
                alignedValue = val
                if fuzzyCompare(val, 0., stepSize) == 0:
                    alignedValue = 0.
                    
                minorTicks.append(alignedValue)
        
        return minorTicks
                
if __name__ == '__main__':
    '''
    print('ceilEps(2., 10.) = ',ceilEps(2., 10.))
    print('floorEps(2., 10.) = ',floorEps(2., 10.))
    print('divideEps(20.,10.) = ',divideEps(20.,10.))
    print('ceil125(1242354.) = ',ceil125(1242354.))
    print('floor125(1242354.) = ',floor125(1242354.))
    
    scale = Scale()
    print('scale.divideInterval(100.,10) = ',scale.divideInterval(100.,10))
    print('scale.autoScale(0, 100, 33) = ',scale.autoScale(0, 100, 33))
    print('scale.buildMajorTicks(0, 10, 1.) = ', scale.buildMajorTicks(0, 10, 1.))
    
    majorTicks = scale.buildMajorTicks(0, 10, 1.)
    print('MinorTicks = ',scale.buildMinorTicks(majorTicks, 2, 1.))
    #print(scale.buildTicks(0., 10., 1., 2))'''
    