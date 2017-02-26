  %One way slab design (simply supported)
  clc;
  clear;
  %Load the input file 
  load slab.mat
  load tables.mat
  %depth by span to depth ratio
  depth=slab.length/(20*1.3);
  %depth by limiting moment
  rulim1=interp2(rulim,rulim,rulim,slab.fy,slab.fck);
  depth1=sqrt(slab.moment/(rulim1*1000));
  %depth by shear
  depth2=slab.shear/(1000*.28);
  output.depth=max([depth,depth1,depth2]);
 
  
  Area_of_one_bar=(pi*slab.main_dia^2/4);
  
  Area_of_steel= .5*slab.fck/slab.fy*1000*output.depth*(1-sqrt(1-(4.62*...
                 slab.moment/(slab.fck*1000*output.depth^2))));
  %percentage of steel 
  pt=Area_of_steel/(1000*output.depth)*100;
  %spacing betweem the bars
  spacing=1000*Area_of_one_bar/Area_of_steel;
  output.spacing=min([spacing,300,3*output.depth]);
  %transverse reinforcement
  Area_of_steel2=.12*10*output.depth;
  spacing2=1000*Area_of_one_bar/Area_of_steel2;
  output.spacing2=min([spacing2,450,5*output.depth]);
  %check for shear
  Tv=slab.shear/(1000*output.depth);
  y=pt/2;
  Tc=interp2(design_shear_stress,design_shear_stress,...
            design_shear_stress,slab.fck,y);
   
  if Tv<Tc
    disp('Design is safe in shear')
    end
  %Check for developement length
  Tbd=interp1(bond_stress(:,1),bond_stress(:,2),slab.fck);
  output.Ld=(.87*slab.fy*slab.main_dia)/(4*Tbd*1.6);
  output.main_steel=Area_of_steel;
  output.distribution_steel=Area_of_steel2;

  output
   
   
   
   
   
   
   
  
  