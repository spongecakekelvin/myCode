# encoding: UTF-8
import threading
#Timer（定时器）是Thread的派生类，
#用于在指定时间后调用一个方法。

class Timer:
	fps = 30
	looptime = 1/30

	def init():


	def delayCall(func, dt):
		dt = dt or 0.01
		timer = threading.Timer(dt, func)
		timer.start()

	def loopCall(func, dt):
		

Timer.init()
