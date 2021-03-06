##
# @package civilsage.views
# This module contain functions to controls veiws of django.
# It include following functions -:
# index()
# matrix() 
# last()
# file() 
# pdfemail()
# first_write()
# ...
# @author amarjeet kapoor

# @code importing modules
import os,threading
from django.http import HttpResponse
from django.shortcuts import render
import csv,datetime
from django.core.mail import EmailMessage

##
# first veiw created by rendering html page
# from templete
# @param request request from civilsage.urls()
# @return request and path to index.html
#
def index(request):
	return render(request, 'civilsage/index.html')

##
# This function display matrix for input from user and take 
# response from index veiw and write input taken through index.html
# and write in input.sage file
# @param request request from index.html
# @return request and path to matrix.html and number of storeys and 
# input taken from index.html
# @exception return message and request to index.html

def matrix(request):

	try:
		#dictionary of all input tags
		
		lists = {'Soil_type':'','Number_of_storeys':''
		,'Importance_factor':'','Response_reduction_factor':''
		,'Zone_factor':'','Gravity_acceleration':''
		,'Modes_considered':'','email_get':''}

		name = ''

		#getting input using tags and sending it as response
		
		for var in lists.keys():
			request.session[var] = request.POST.get(var)

		#creating directory from base directory
		
		lists['Number_of_storeys'] = request.POST.get('Number_of_storeys')

		#making list for iteratation in templete
		
		number_of_storeys = list()
		
		#name of directory of specific user
		
		for a in range(int(lists['Number_of_storeys'])):
			number_of_storeys.append('a')

		#calling differnet veiws based on option whether
		#manually

		if(request.POST.get('through_file')=='Y'):
			return render( request,'civilsage/file.html'
			,{'number_of_storeys': number_of_storeys,
			'email_get': request.POST.get('email_get')})
		else:
		#user want to upload matrix value through file or
		
			return render( request,'civilsage/matrix.html'
			,{'number_of_storeys': number_of_storeys,
			'email_get': request.POST.get('email_get') })
	except:
		return render(request, 'civilsage/index.html'
		,{'message':'please fill again'})


##
# This function gets request from matix.html and
# gives pdf as output to user it call civil.sh to process inputs and get output
# @param request request from matrix.html
# @return request and message to index.html 
# @return pdf as response 
# @exception return message and request to index.html

def last(request):

	message='error occured please fill again'
	try:
		#calling function to writte basic input
		name,message=first_write(request)
		#getting numbers of storeys
		num = request.session.get('Number_of_storeys')

		#opening input.sage to append remaining inputs
		command=name+'/input.sage'
		file=open(command,'a')

		#list of basic tags
		var = ['mass','Height_storey','Stiffness_storey']

		#writing matix into sage file
		for j in var:
			file.write(j)
			file.write('=matrix([')

			#writing elements of matix
			for i in range(int(num)):

				#creating input tags
				temp = j+str(i)
				file.write('[')

				#getting input from tags
				d=request.POST.get(temp)
				file.write(d)
				file.write(']')

				#condition to check last element
				if( i!=int(num)-1):
					file.write(',')
			file.write('])\n')
		file.close()

		if(request.POST.get('email_id')):
			#calling funcion to send pdf and run that as background process
			thread = threading.Thread(target=pdfemail,args=(request,name))
			thread.daemon = True
			thread.start()
			message="PDF send to "+request.POST.get('email_id')
			return render(request, "civilsage/index.html", {'message':message})
		else:

			#calling sh file for background processing
			command='sh  civil.sh '+name
			os.system(command)

			#opening creted pdf to display to user
			command=name+'/civil.pdf'
			f=open(command)

			#sending pdf as response
			response = HttpResponse(f,content_type='application/pdf')
			response['Content-Disposition'] = 'attachment; filename="civil.pdf"'
			#deleting temperary files
			command='rm -rf '+name
			os.system(command)
			return response
	except:
		return render(request, "civilsage/index.html",
		{'message':message,'email_get':request.session.get('email_get')})


##
# This veiw take input data from file uploaded by user and processes
# to give output in form of response.
# It call civil.sh to process
# @param request request from matrix.html
# @return render() request and message to index.html 
# @return response pdf as response 
# @exception return message and request to file.html

def file(request):

	message='please fill again'
	try:
		name,message=first_write(request)
		#getting file uploaded by user
		f=request.FILES["input_file"]
		if(f.content_type != 'text/csv'):
			return render( request,'civilsage/file.html',
			{'email_get': request.session.get('email_get'),
			'message':'File Not in CSV FORMAT '})
		data = [row for row in csv.reader(f)]
		#getting numbers of storeys
		num = request.session.get('Number_of_storeys')

		#opening input.sage to append remaining inputs
		command=name+'/input.sage'
		file=open(command,'a')
		#list of basic tags
		var = ['mass','Height_storey','Stiffness_storey']
		jar=0

		#writing matix into sage file
		for j in var:
			message="Less no. of rows in csv file"
			file.write(j)
			file.write('=matrix([')

			#writing elements of matix
			for i in range(int(num)):
				file.write('[')

				#getting input from tags
				message="Less no. of elements in row "+str(j)
				if(not data[jar][i].isdigit()):
					ii=i+1
				else:
					ii=i
				d=data[jar][ii]
				file.write(str(d))
				file.write(']')

				#condition to check last element
				if( i!=int(num)-1):
					file.write(',')
			jar=jar+1
			file.write('])\n')
		file.close()
		if(request.POST.get('email_id')):
			#calling funcion to send pdf and run that as background proces
			thread = threading.Thread(target=pdfemail,args=(request,name))
			thread.daemon = True
			thread.start()
			message="PDF will be send to "+request.POST.get('email_id')
			return render(request, "civilsage/index.html", {'message':message})
		else:
			command='sh  civil.sh '+name
			os.system(command)

			#opening creted pdf to display to user
			command=name+'/civil.pdf'
			f=open(command)

			#sending pdf as response
			response = HttpResponse(f,content_type='application/pdf')
			response['Content-Disposition'] = 'attachment; filename="civil.pdf"'
			#deleting temperary files
			command='rm -rf '+name
			os.system(command)
			return response
	except:
		command='rm -rf '+name
		os.system(command)
		return render(request, "civilsage/file.html",
		{'message':message,'email_get':request.session.get('email_get')})

##
# A function that run as background process to send pdf as emails and called
# by last() and file() when email option is chossen
# @param request request from calling function 
# @param name name of directory to becreated for user
# @exception send error message through email 

def pdfemail(request,name):

	message='unable to send it will be send after sometime'
	try:
		#creating and writing sh file for background processing
		email_id=request.POST.get('email_id')
		command=name+'/email.txt'
		f=open(command,'w')
		f.write(email_id)
		f.close()
		command='sh  civil.sh '+name
		os.system(command)
		command=name+'/civil.pdf'
		email_id=request.POST.get('email_id')
		user_email = EmailMessage('Dynamics of structure',
		'You have is ready', to=[email_id])
		user_email.attach_file(command)
		message='wrong email id'
		user_email.send()
		command='rm -rf '+name
		os.system(command)
	except:
		command='rm -rf '+name
		if(message=='wrong email id'):
                    os.system(command)
                email_id=request.POST.get('email_id')
		user_email = EmailMessage('Dynamics of structure',
		message, to=[email_id])

##
# This function that write basic input same for all veiws and called
# by last() and file() when email option is chossen
# @param request request from calling function 
# @return name,message name of directory and Error message  

def first_write(request):
	message='error occured please fill again'

	#dictionary of all input tags
	lists = {'Soil_type':'','Number_of_storeys':''
	,'Importance_factor':'','Response_reduction_factor':''
	,'Zone_factor':'','Gravity_acceleration':''
	,'Modes_considered':''}
	#name of directory of specific user
	name='Temp'+request.session.session_key+str(datetime.datetime.now())
	name=name.replace(" ", "")
	#getting input using tags
	for var in lists.keys():
		lists[var]=request.session.get(var)
		name=name+str(lists[var])
	command='cp -r sagemath '+name
	os.popen(command)

	#opening file for writing
	command=name+'/input.sage'
	file = open(command, 'w')

	#writing variables in input.sage file with syntax of sage
	for var in lists.keys():
		file.write(var)
		file.write('=')
		file.write(lists[var])
		file.write('\n')
	file.close()
	return name,message
