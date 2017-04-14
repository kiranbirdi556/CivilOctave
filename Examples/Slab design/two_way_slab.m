%Two way slab using IS 456 2000
clc;
clear;

load slab.mat
load bending_coeff.mat
load tables.mat
 
 %Ratio of longer span to shorter span 
 ratio=slab.width/slab.length

 %depth by span to depth ratio
  disp("Span to depth ratio acc. to clause 23.2.1 IS 456 ")
  disp ('span/depth=25')
  depth=slab.length/(25)
  fprintf("\n");

  %Total depth
  disp("Total depth")
  D=(depth+slab.clearCover+slab.mainDia/2)
  fprintf("\n");

  %Dead load
  disp("Dead load")
  slabload=D*25*.001;
  DL=slabload+slab.floorLoad
  fprintf("\n");

  %Total load= Dead load + Live load
  TL=DL+slab.liveLoad;
  fprintf("\n");
  
  %Factored load=1.5 *Total load
  disp("Factored load=1.5(dead load+live load")
  FL=1.5*TL
  fprintf("\n");
  
  %Bending moment coefficient for the main and transverse span 
  
   %coeff for moment in shorter direction
   alphaxn=interp2(moment_coefficient,moment_coefficient,moment_coefficient,...
                  ratio,slab.coeff(1,1))
                  
   alphaxp=interp2(moment_coefficient,moment_coefficient,moment_coefficient,...
                  ratio,slab.coeff(1,2))
                  
   alphayn=interp2(moment_coefficient,moment_coefficient,moment_coefficient,...
                  10,slab.coeff(1,1))
  
   alphayp=interp2(moment_coefficient,moment_coefficient,moment_coefficient,...
                  10,slab.coeff(1,2))
                  
   fprintf("\n");               
                  
   %Bending moment in x and y direction
   momentxp=alphaxp*FL*slab.length*slab.length
   momentxn=alphaxn*FL*slab.length*slab.length
   momentyn=alphayn*FL*slab.length*slab.length
   momentyp=alphayp*FL*slab.length*slab.length
   
   fprintf("\n");
   
   %maximum shear for the slab
   shear=FL*slab.length/2
   fprintf("\n");
   
   %middle strip of slab in longer and shorter direction
   msL=3/4*slab.width
   msS=3/4*slab.length
   fprintf("\n");
  
   %edge strip for the longer and shorter direction
   esL=slab.width/8
   esS=slab.length/8
   fprintf("\n");
   
  % Rulimiting for the slab acc to the fck and fy 
   Ru_lim=interp2(rulim,rulim,rulim,slab.fy,slab.fck)
   fprintf("\n");
   
   %maximum moment out of four moment 
   maxMoment=max([momentxp,momentxn,momentyn,momentyp])
   fprintf("\n");
   
   
   %depth from maximum moment 

   depth1=sqrt(maxMoment/(Ru_lim*1000))
   fprintf("\n");
   
   %depth by shear
  disp("depth by shear")
  shearDepth=shear/(1000*.28)
  fprintf("\n");
  
  %Effective depth 
  disp("effective depth=maximum of lim depth ,depth from span/25,shear depth")
  effDepth=max([depth1,depth,shearDepth])
  fprintf("\n");
   
   %check for shear
  disp("check for shear acc to clause 40 IS 456 2000 at minimum reinforcemenr")
  Tv=shear/(1000*effDepth)
  fprintf("\n");
  
  %Table 19 IS 456 2000 <15%
  Tc=.28
   
  if Tv<Tc
    disp('Design is safe in shear')
    end
  fprintf("\n");
  
   Area_of_one_bar=(pi*slab.mainDia^2/4)
   
   %Area of steel provided in the shorter  direction in the middle strip
  disp("Area of steel required in the shorter direction per meter width")
  Area_of_steel_x= .5*slab.fck/slab.fy*1000*effDepth*(1-sqrt(1-(4.62*...
                 momentxp/(slab.fck*1000*effDepth^2))))
                 
   %Area of steel provided in the longer  direction in the middle strip
  disp("Area of steel required in the longer direction per meter width")
  Area_of_steel_y= .5*slab.fck/slab.fy*1000*effDepth*(1-sqrt(1-(4.62*...
                 momentyp/(slab.fck*1000*effDepth^2)))) 
    
     %Area of steel provided in the shorter  direction in the middle strip
  disp("Area of steel required in the shorter direction per meter width")
  Area_of_steel_xn= .5*slab.fck/slab.fy*1000*effDepth*(1-sqrt(1-(4.62*...
                 momentxn/(slab.fck*1000*effDepth^2))))
                 
    %Area of steel provided in the shorter  direction in the middle strip
  disp("Area of steel required in the shorter direction per meter width")
  Area_of_steel_yn= .5*slab.fck/slab.fy*1000*effDepth*(1-sqrt(1-(4.62*...
                 momentyn/(slab.fck*1000*effDepth^2))))
   
   %Area of steel required in the edge strip per meter width
    Area_of_steel_edge=.12*10*effDepth
  fprintf("\n");
  
  %minimum area of steel required
  minArea=.12*10*effDepth
  
  %provided area of steel for various moments
  Area_of_steel_x=max([minArea,Area_of_steel_x])
  Area_of_steel_xn=max([minArea,Area_of_steel_xn])
  Area_of_steel_y=max([minArea,Area_of_steel_y])
  Area_of_steel_yn=max([minArea,Area_of_steel_yn])

  %spacing betweem the bars
  disp("spacing of bars of shorter middle strip reinforcement")
   spacing=1000*Area_of_one_bar/Area_of_steel_x;
   spacing_x=min([spacing,300,3*effDepth])
   fprintf("\n");
   
   disp("spacing of bars of longer middle strip reinforcement")
   spacing=1000*Area_of_one_bar/Area_of_steel_y;
   spacing_y=min([spacing,300,3*effDepth])
   fprintf("\n");
   
   disp("spacing of bars of shorter middle strip reinforcement")
   spacing=1000*Area_of_one_bar/Area_of_steel_xn;
   spacing_xn=min([spacing,300,3*effDepth])
   fprintf("\n");
   
   disp("spacing of bars of shorter middle strip reinforcement")
   spacing=1000*Area_of_one_bar/Area_of_steel_yn;
   spacing_yn=min([spacing,300,3*effDepth])
   fprintf("\n");
  
   %Check for span to depth ratio
   fs=.58*slab.fy;
   
   disp("developement length acc to clause 26.2.1 IS 456 2000")
  Tbd=interp1(bond_stress(:,1),bond_stress(:,2),slab.fck)
  Ld=(.87*slab.fy*slab.mainDia)/(4*Tbd*1.6)
  
  %Total depth
  disp("Total depth")
  D=(effDepth+slab.clearCover+slab.mainDia/2)
  fprintf("\n");
  

   result.effective_depth=effDepth;
   result.overall_depth=D;
   result.shorterPositiveSpacing=spacing_x;
   result.longerPositiveSpacing=spacing_y;
   result.shorterNegativeSpacing=spacing_xn;
   result.longerNegativeSpacing=spacing_yn;
   result.provided_dia=slab.mainDia;
   slab
   result
   
  
  
  
  
  
  
  
  
  
  
  