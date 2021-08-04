# W=a+bw+cH
# H=a+bH+cW
#
require 'gnuplot'


def plot(title,llxy, type)
	Gnuplot.open do |gp|
	   Gnuplot::Plot.new(gp) do |plot|
		   plot.title title
		   plot.xrange "[0:#{llxy.first(2).last.max}]"
		   llxy.each_slice(3) {|name,lx,ly|
			 plot.data << Gnuplot::DataSet.new([lx, ly]) do |ds|
			  ds.with =  type
			  ds.title=  name
			 end
		   }
		end
	end
end
def rplot(title,lxy, labels, type)
	Gnuplot.open do |gp|
	   Gnuplot::Plot.new(gp) do |plot|
		   plot.title title
		   #plot.xrange "[0:#{llxy.first(2).last.max}]"
		   labels.size.times {|index|
		      lx= lxy.map {|a|a.first}
		      ly= lxy.map {|a|a[1+index]}
			  label=labels[index]
			  plot.data << Gnuplot::DataSet.new([lx, ly]) do |ds|
			    ds.with =  type
			    ds.title=  label
			  end
		    }
		end
	end
end