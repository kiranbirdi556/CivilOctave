 %One way slab design (simply supported)
  clc;
  clear;
  
  %Load the input file 
  load slab.mat
  load tables.mat
  
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
  
  %Factored load=1.5 *Total load
  disp("Factored load=1.5(dead load+live load")
  FL=1.5*TL
  fprintf("\n");

  %Effective span
  disp("Effective span acc. to clause 22.2 IS 456-2000")
  a=slab.length+slab.supportWidth;
  b=slab.length+depth;
  effectiveSpan=min(a,b)
  fprintf("\n");

  %Ultimate moment and shear
  disp("Ultimate moment and shear force")
  moment=FL*effectiveSpan^2/8
  shear=FL*effectiveSpan/2
  fprintf("\n");

  
 %depth by limiting moment
  disp("depth by limiting moment")
  rulim1=interp2(rulim,rulim,rulim,slab.fy,slab.fck);
  limDepth=sqrt(moment/(rulim1*1000))
  fprintf("\n");

  %depth by shear
  disp("depth by shear")
  shearDepth=shear/(1000*.28)
  fprintf("\n");
 
  %Effective depth 
  disp("effective depth=maximum of lim depth ,depth from span/25,shear depth")
  effDepth=max([limDepth,depth,shearDepth])
  fprintf("\n");
  
  %check for shear
  disp("check for shear acc to clause 40 IS 456 2000 at minimum reinforcemenr")
  Tv=shear/(1000*effDepth)
  
  %Table 19 IS 456 2000 <15%
  Tc=.28
   
  if Tv<Tc
    disp('Design is safe in shear')
    end
  fprintf("\n");

  Area_of_one_bar=(pi*slab.mainDia^2/4);
  
  %Area of steel provided in the main direction
  disp("Area of steel required in the main direction per meter width")
  Area_of_steel= .5*slab.fck/slab.fy*1000*effDepth*(1-sqrt(1-(4.62*...
                 moment/(slab.fck*1000*effDepth^2))))
  fprintf("\n");
               
  %percentage of steel 
  pt=Area_of_steel/(1000*effDepth)*100;
  
  %spacing betweem the bars
  disp("spacing of bars of main reinforcement")
   spacing=1000*Area_of_one_bar/Area_of_steel;
   mainspacing=min([spacing,300,3*effDepth])
   fprintf("\n");

  %Check for span to depth ratio
  fs=.58*slab.fy;
 
  %transverse reinforcement
  disp("transverse reinforcement provided as minimum reinforcement")
  Area_of_steel2=.12*10*effDepth
  fprintf("\n");

  %spacing of transverse reinforcement
  disp("spacing of transverse reinforcement")
  spacing2=1000*Area_of_one_bar/Area_of_steel2;
  secspacing2=min([spacing2,450,5*effDepth])
  fprintf("\n");
   
  %Check for developement length
  disp("developement length acc to clause 26.2.1 IS 456 2000")
  Tbd=interp1(bond_stress(:,1),bond_stress(:,2),slab.fck)
  Ld=(.87*slab.fy*slab.mainDia)/(4*Tbd*1.6)
  
  L0=min(12*slab.mainDia,effDepth);
  Ld1=(moment/shear)+L0;
  if Ld1>Ld
     disp('design is safe in bond anchorage')
     end
  fprintf("\n");
        
  %check for shear
  disp("check for shear with provided reinforcement")
  Tv=shear/(1000*effDepth)
  y=pt/2;
  Tc=interp2(design_shear_stress,design_shear_stress,...
            design_shear_stress,slab.fck,y)
   
  if Tv<Tc
    disp('Design is safe in shear')
    end
   
   result.moment=moment;
   result.shear=shear;
   result.effective_depth=effDepth;
   result.overall_depth=D;
   result.longitudnal_spacing=mainspacing;
   result.transverse_spacing=secspacing2;
   result.provided_dia=slab.mainDia;
   slab
   result
   
   
   
   
   
   
  
  