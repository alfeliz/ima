###########################################################################################
#
#
#  OCTAVE SCRIPT TO SEE THE EDGES OF AN STREAK IMAGE AND TRANSFORM THE DATA:
#    Made by Gonzalo Rodríguez Prieto
#       (gonzalo#rprieto AT uclm#es)
#       (Mail: change "#" by "." and "AT" by "@"
#              Version 3.30
#
#
#########################################################
#
#   It uses the functions:
#        display_rounded_matrix
#	 	 supsmu
#        deri
#  They must be in the same directory.
#
###########################################################################################

tic; #Control total computing time.

#Empty memory from user created variables:
clear;


###
# Declaration of important variables:
###

#String with the file name:
filename = input("Wich file to use? (Include extension)\n","s");
%filename = "ALEX099_Streak.dat"; #(For testing purposes)

[file, msg] = fopen(filename, "r");
if (file == -1) 
   error ("Unable to open file name: %s, %s",filename, msg); 
endif; 

#Standard deviation parameter (Value to make the binarization)
std_dev_par = 35; #This seems to work, change if results are very bad.

#Sweep range (For later calibration)
sweep = 097.66; #nanosec/px (For 50 microseconds in 512 rows in the picture.) [50 000 / 512]

#Charge the image as a matrix: (IT MUST BE ALREADY FORMATTED AS SUCH)
T = dlmread(file);
fclose(file);

#Rounding values for the text final file:
redond_01 = [0 0 0];
redond_02 = [0 0 0 0 0 0 0];

#The binarized matrix. empty with zeroes now:
Out = zeros(rows(T),columns(T));

#The output vector. As before, it starts with zeroes inside:
move = zeros(rows(T),10);

#Maximum of the matrix/2. For showing the results in images and finding edges.
valout = max(max(T))/2;


###
# Making the binarized matrix.
###
#   Loop to fill the OUT matrix with the positions and binarized image: 
#  It places "valout" on the output matrix. So this matrix has only two values: 0
# and "valout". Then it is easy to look for the external edges.
#  It is done on a double loop because with vector logics and so on,
# the program gives not right results.

for i = 1 : rows(T) #For every row of the picture...
    row = T(i,:); # put the row on a variable.
    if ( std(row) > std_dev_par ) #When there is data on the row, no just noise ->
    % Signaled by a standard deviation higher than "std_dev_par".
      halfrow = max(row)/2; # Take half of the maximum value for this row and use it as mark for margins
	for j = 1 : columns(T)
           %  In every column of the OUT row change the value to "valout" if 
           % the column value is higher than halfrow.
	   if ( row(j) > halfrow )
	     Out(i,j) = valout;
	   endif;
	endfor;
    endif;
endfor;


###
# Find the positions of the edges in the binary matrix
###
#Loop for finding the real positions pixels table:

j = 0; %Initialize the "j" variable.
for i = 1 : rows(Out) #For every row of the picture...
   pos = find(Out(i,:)==valout); # Find the positions of "valout" in the output matrix and
   % store them in an index vector(POS)
   if (columns(pos) > 1) #When there are really values
     j = j+1;
     move(j,1) = i; #First column is time (In pixels units)
     move(j,2) = pos(1); #Second column is space on "first" side
     move(j,3) = pos(end); #Third column is space on the "last" side
     if (j==1) #Finding the center position for the first column:
       zenter = abs(move(1,2)-move(1,3))/0.5 + min(move(1,2),move(1,3));
     endif;
   endif;
endfor;


###
# Data treatment
###

#Remove the zeros on the matrix results:
 move = move( (move(:,2)!=0),:); #Take out the positions were the second column has zero value.
#(Made using logical indexing)

#Calibration of pixels in time and space and centering:
#CAREFUL: THIS CALIBRATION IS VALID FROM ALEX086 TO ALEX099 ONLY !!!!!
move(:,4) = move(:,1) .* sweep; #Passing pixels to nanoseconds.
move(:,5) = (move(:,2)-zenter) .* 0313; #Passing pixels to micrometers and centering.
move(:,6) = (move(:,3)-zenter) .* 0313; #Passing pixels to micrometers and centering.

#smoothing radius data with the function "supsmu", check function help to see how it works:
move(:,5) = supsmu(move(:,4),move(:,5),"span",0.01);
move(:,6) = supsmu(move(:,4),move(:,6),"span",0.01);

###
# Data transforming
###

#Deriving to obtain velocity (in micrometers/nanosecond):
  h = abs(move(10,4)-move(11,4));
dev = deri(move(:,5),h);
dev2 = deri(move(:,6),h);
move(1:columns(dev),7) = 1000 .* dev; #Transforming it in m/s from um/ns and placing it in the "move" matrix.
move(1:columns(dev),8) = 1000 .* dev2; #Transforming it in m/s from um/ns and placing it in the "move" matrix.

#Putting in zero the radius displacement
move(:,5) = move(:,5) - min(move(:,5)); 
move(:,6) = move(:,6) - min(move(:,6)); 


# Estimating plasma pressure (Rankine-Hugoniot conditions)

#Obtaining maximun velocity in each side:
v1 = max(abs(move(:,7)))
v2 = max(abs(move(:,8)))

#Using pressure relation:
gama = 1.6; #Gamma values for monoatomic gas.
c = 340; #m/s. sound velocity in air.
RelaPres1 = 1 + ( (2*gama)/(gama + 1) ) * [(v1/c)**2 + 1 ];
RelaPres2 = 1 + ( (2*gama)/(gama + 1) ) * [(v2/c)**2 + 1 ];
#Calculating pressure over time:
vel = move(1:columns(dev),7);
move(1:columns(dev),9) =  1 + ( (2.*gama)./(gama + 1) ) .* [(vel./c).**2 + 1 ];
vel = move(1:columns(dev),8);
move(1:columns(dev),10) =  1 + ( (2.*gama)./(gama + 1) ) .* [(vel./c).**2 + 1 ];

disp("Pressure one side:")
disp(RelaPres1)
disp(" atm")  
disp("Pressure other side:")
disp(RelaPres2)
disp(" atm")  

###
# Data saving
###

#Saving the vector with the data:
#Output file names:
name = strtok(filename,"."); #Taking tha name from "filename".
name1 = horzcat(name,"_data_01.txt"); #Adding the right sufix.
output1 = fopen(name1,"w"); #Opening the file.
fdisp(output1,"time(px)  space_l(px)  space_r(px)"); #First line.
display_rounded_matrix(move(:,1:3), redond_01, output1); #This function is not made by my.
fclose(output1);
name2 = horzcat(name,"_data_02.txt"); #Adding the right sufix.
output2 = fopen(name2,"w"); #Opening the file.
fdisp(output2,"time(ns)  space_l(um) space_r(um) vel_l(m/s) vel_r(m/s) pre_l(atm) pre_r(atm)"); #First line.
display_rounded_matrix(move(:,4:10), redond_02, output2); #This function is not made by my.
fclose(output2);
#Making the merging of the two images matrices:
finim = [T Out];
#Writing the combined image file:
name = strtok(filename,".");
name = horzcat(name,"_images.jpg");
imwrite(uint8(finim),name); #The uint8 function converts to 8 bits the original 16bits function.

timing = toc; 


###
# Total processing time
###

disp("Script ima execution time:")
disp(timing)
disp(" seconds")  


#That's...that's all folks!!!
