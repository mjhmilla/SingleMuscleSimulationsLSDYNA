# With this file we control the LS-Dyna runs at the ITM Uni Stuttgart
# written by Joerg Fehr 2014-05-07 17:00:39
# 
# 

# 
Version=R7.1.1

Dyna_Command=/scratch/tmp/mmillard/SMP_R931/lsdyna

Compress_Command=hvtrans
Compress_Config=ITM_ZF_TRW_Fareside_Translation.cfg
Main_File=concentric_100g
MEMORY=999999999

run:
	$(Dyna_Command) I=$(Main_File).k MEMORY=$(MEMORY) NCPU=4
    
check:  
	$(Dyna_Command) I=$(Main_File).k MEMORY=$(MEMORY) NCPU=4 MCHECK=y    
    
debug:
	ddd $(Dyna_Command) --args I=$(Main_File).k MEMORY=$(MEMORY) NCPU=1 JOBID=$(Main_File)
	
	
message:
	kate -b $(Main_File).messag
	
clean:
	rm -f *.nodout *.binout *.d3plot* nodout d3plot* messag d3hsp d3eigv d3dump1 adptmp *.K_0001_001*.rhs.rb  *.M_0001_001*.rhs.rb\
	     *.d3mode *.d3eigv *.d3hsp *.bg_switch *~ *.kill_by_pid *.messag *.TEST *.eigout *.camodeout
	     *.spooles.res
tidy:   
	rm -f *.kill_by_pid *.d3hsp *.d3dump01 *.bg_switch	

rm_results:
	rm -f abstat bg_switch binout d3thdt deforc elout glstat jntforc matsum\
		rcforc rwforc secforc d3plot*  sleout ssstat status.out  *.mtx.rb  \
		*.Node_Data_0001_001 *.abstat *.bg_switch *.binout *.d3thdt \
		*.deforc *.elout *.glstat *.jntforc *.matsum *.rcforc *.rwforc \
		*.secforc *.d3plot* *.sleout *.ssstat *.status.out	

compress:
# 	$(Compress_Command) -c$(Compress_Config) $(Main_File).d3plot -o$(Main_File).h3d -z0.01
	$(Compress_Command) -c$(Compress_Config) d3plot -o$(Main_File).h3d -z0.01
	
# nohup /lustre/ws1/fehr/scripts/LSDoE_start.sh -c start.cfg > LSDoE_out.log 2>&1 &
		
