#!/bin/env python

import os
import itertools
import matplotlib 
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import mysql.connector
from mysql.connector.errors import Error

def cnv_plot_all_bowtie_bwa(con, input_table, pos, filter_column1, filter_value1, data_column1, bowtie_bwa_ratio, y_limit, title_label, dir_path):
	colors = itertools.cycle(['black','red','green','blue','cyan','magenta','yellow','gray'])
	image_name = "%s.png" % title_label
	os.chdir(dir_path)
	fig = plt.figure(1, figsize=(23, 6), dpi=600)

	get_ref_exon_contig_id = "SELECT DISTINCT ref_exon_contig_id FROM `%s` WHERE %s='%s';"
	#print(get_ref_exon_contig_id % (input_table, filter_column1, filter_value1))

	cursor = con.cursor()
	try: 
		status = cursor.execute(get_ref_exon_contig_id % (input_table, filter_column1, filter_value1))
		i_ref_exon = cursor.fetchall()
		if not i_ref_exon:
			print("The query[ %s ] returns 0 rows" % get_ref_exon_contig_id)
			exit(-1)	
		n1 = len(i_ref_exon)
		for j in range(0,n1):
			colour = next(colors)
			filter_value2 = i_ref_exon[j][0]
			get_data = "SELECT DISTINCT %s, %s, %s FROM `%s` WHERE %s='%s' AND ref_exon_contig_id='%s' ORDER BY %s ASC;"
			status2 = cursor.execute(get_data % (pos, data_column1, bowtie_bwa_ratio, input_table, filter_column1, filter_value1, filter_value2, pos))
			i_data = cursor.fetchall()
			if not i_data: 
				#print("NO DATA FOUND")
				plt.plot(0, 0.07, 'o', mfc='none', mec='b')
				plt.text(-0.95, 0.5, 'This gene has no coverage data')
				plt.xlim(-1, 1)
				plt.ylim(-0.3, y_limit) 
				plt.xlabel('chromosome position')
				plt.ylabel('ratio')
				plt.title(title_label)
			else: 
				n = len(i_data)
				num_exon = 0
				# Min-Max over POS
				xmin = min(i_data, key=lambda t: t[0])[0]
				xmax = max(i_data, key=lambda t: t[0])[0]
				x_min = xmin-5
				x_max = xmax+5

				if j == 0:
					plt.xlim(-200, n+200)
					plt.ylim(-0.3, y_limit) 
					plt.xlabel('chromosome position')
					plt.ylabel('ratio')
					plt.title(title_label)
					plt.plot(0, 0.07, 'o', mfc='none', mec='b')
					plt.axhline(y=0.5, color='b')
					plt.axhline(y=0.4, color='b')
					plt.axhline(y=0.3, color='b')
					plt.axhline(y=0.2, color='b')
					plt.axhline(y=0.1, color='b')
					plt.axhline(y=1, color='b', ls='dashed')
					plt.text(0, 0, num_exon, size='6')
				altPlot = 1
				for i in range(1,n):
					data_value1 = i_data[i][0]
					data_value2 = i_data[i][1]
					data_value3 = i_data[i][2]
					plt.plot(i, data_value2, '+', mec=colour, mfc='none')
					plt.plot(i, data_value3, '*', mec='red', mfc='red')
					extra=0.05*((n+1)/2)
					plt.xlim(-1-extra, n+extra)
					plt.ylim(-0.3, y_limit+0.3) 
					if (i_data[i][0] - i_data[i-1][0]) > 1:
						num_exon = num_exon + 1
						plt.text(i, 0, num_exon,size='6')
						if altPlot == 1: 
							plt.text(i, -0.1, data_value1,size='6')
							altPlot = -1
						else: 
							plt.text(i, -0.2, data_value1,size='6')
							altPlot = 1
						plt.plot(i, 0.07, 'o', mfc='none', mec='b', linestyle='None')
			j=j+1
	except mysql.connector.Error as e: 
		print("Error code:", e.errno)        # error number
  		print("SQLSTATE value:", e.sqlstate) # SQLSTATE value
		print("Error message:", e.msg)       # error message
		print("Error:", e)                   # errno, sqlstate, msg values
		s = str(e)
		print("Error:", s)                   # errno, sqlstate, msg values
	plt.savefig(image_name)	
	cursor.close()
	
con = mysql.connector.connect(user='root',
                              host='127.0.0.1',
                              database='cnv',
			                  unix_socket='socket_path')
dir_path = "sample_path";
os.chdir(dir_path)

